#!/usr/bin/env bash
# Shared agent/git validation hook: runs Prek (.pre-commit-config.yaml) on the
# uncommitted files and reports the result in each agent's hook protocol.
#
#   --adapter claude       .claude/settings.json, Stop. Blocks with
#                          {"decision":"block"} JSON so Claude sees the reason.
#   --adapter codex        .codex/hooks.json, Stop. Same JSON protocol.
#   --adapter antigravity  .antigravitycli/hooks.json, PostInvocation. Same
#                          JSON protocol; needs "enableJsonHooks": true in the
#                          user's Antigravity CLI settings.
#   --adapter copilot      .github/hooks/prek-validation.json, preToolUse.
#                          Copilot has no end-of-turn hook, so a failure denies
#                          one tool call, then a recovery sentinel lets calls
#                          through for up to 10 minutes while the agent fixes it
#                          (protocol for the model: .github/copilot-instructions.md).
#   --adapter plain        Manual runs: reason on stderr, exit 2 on failure.
#
# State lives in .git/prek-hook: the hash of the last passing state (to skip
# re-running Prek) and of the last blocked state (so a Stop hook stops
# blocking once the agent makes no further changes).
set -euo pipefail

ADAPTER=plain
if [ "${1-}" = "--adapter" ]; then
  if [ "$#" -lt 2 ]; then
    printf 'Missing value for --adapter\n' >&2
    exit 2
  fi
  ADAPTER=$2
  shift 2
elif [[ "${1-}" == --adapter=* ]]; then
  ADAPTER=${1#--adapter=}
  shift
fi

case "$ADAPTER" in
  claude | plain | codex | copilot | antigravity) ;;
  *)
    printf 'Unknown Prek lint hook adapter: %s\n' "$ADAPTER" >&2
    exit 2
    ;;
esac

# Stop-hook payloads arrive as JSON on stdin. Claude and Codex set
# stop_hook_active when the agent is already continuing because of this hook.
hook_input=
case "$ADAPTER" in
  claude | codex | copilot)
    hook_input=$(cat || true)
    ;;
esac

stop_hook_active=false
if [[ "$hook_input" =~ \"stop_hook_active\"[[:space:]]*:[[:space:]]*true ]]; then
  stop_hook_active=true
fi

json_escape() {
  local value=${1-}
  value=${value//\\/\\\\}
  value=${value//\"/\\\"}
  value=${value//$'\n'/\\n}
  value=${value//$'\r'/}
  value=${value//$'\t'/\\t}
  printf '%s' "$value"
}

allow() {
  case "$ADAPTER" in
    codex)
      printf '{}\n'
      ;;
    antigravity)
      printf '{"decision":"allow"}\n'
      ;;
  esac
  exit 0
}

deny() {
  local reason=$1
  case "$ADAPTER" in
    claude | codex | antigravity)
      printf '{"decision":"block","reason":"%s"}\n' "$(json_escape "$reason")"
      exit 0
      ;;
    copilot)
      printf '{"permissionDecision":"deny","permissionDecisionReason":"%s"}\n' "$(json_escape "$reason")"
      exit 0
      ;;
    plain)
      printf '%s\n' "$reason" >&2
      exit 2
      ;;
  esac
}

hash_repo() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256
  else
    sha256sum
  fi
}

file_mtime() {
  stat -c %Y "$1" 2>/dev/null || stat -f %m "$1" 2>/dev/null || echo 0
}

if [ -z "${PROJECT_ROOT-}" ]; then
  if [ "$ADAPTER" = "antigravity" ] && [ -n "${ANTIGRAVITY_PROJECT_DIR-}" ]; then
    PROJECT_ROOT=$ANTIGRAVITY_PROJECT_DIR
  else
    PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
  fi
fi

STATE_DIR=$(git -C "$PROJECT_ROOT" rev-parse --absolute-git-dir 2>/dev/null || printf '%s' "$PROJECT_ROOT/.git")/prek-hook

# Every uncommitted (non-deleted) file is handed to Prek; the `files:` patterns
# in .pre-commit-config.yaml decide which hooks apply.
changed_files=()
while IFS= read -r file; do
  changed_files+=("$file")
done < <(
  cd "$PROJECT_ROOT"
  {
    git diff --name-only --diff-filter=d HEAD 2>/dev/null
    git ls-files --others --exclude-standard 2>/dev/null
  } | awk '!seen[$0]++'
)

# Content hash of everything the result depends on: HEAD, the Prek config and
# the files under validation. Used to skip re-running checks that already
# passed and to tell whether the agent changed anything since the last block.
state_hash() {
  (
    cd "$PROJECT_ROOT"
    git rev-parse HEAD 2>/dev/null || true
    for file in .pre-commit-config.yaml "${changed_files[@]}"; do
      printf '%s\0' "$file"
      if [ -f "$file" ]; then
        cat -- "$file"
      fi
    done
  ) | hash_repo | cut -d' ' -f1
}

run_prek() {
  if [ ${#changed_files[@]} -eq 0 ]; then
    return 0
  fi

  local hash passed_file
  hash=$(state_hash)
  passed_file="$STATE_DIR/passed-hash"
  if [ -f "$passed_file" ] && [ "$(cat "$passed_file")" = "$hash" ]; then
    return 0
  fi

  (cd "$PROJECT_ROOT" && nix develop ./nix -c prek run --files "${changed_files[@]}") || return

  mkdir -p "$STATE_DIR"
  printf '%s\n' "$hash" >"$passed_file"
}

failure_reason() {
  local output=$1
  printf 'Prek validation failed.\n\nRun from the repo root: nix develop ./nix -c prek run --files %s\n\nOutput:\n%s' "${changed_files[*]}" "$output"
}

run_standard_adapter() {
  local output reason hash blocked_file
  blocked_file="$STATE_DIR/blocked-hash"
  if ! output=$(run_prek 2>&1); then
    reason=$(failure_reason "$output")
    hash=$(state_hash)

    # Loop guard: if the agent was already sent back by this hook and changed
    # nothing since, stop blocking so it can hand the failure to the user.
    if [ "$stop_hook_active" = true ] && [ -f "$blocked_file" ] && [ "$(cat "$blocked_file")" = "$hash" ]; then
      printf '%s\n\nNo changes since the last block; allowing stop.\n' "$reason" >&2
      allow
    fi

    mkdir -p "$STATE_DIR"
    printf '%s\n' "$hash" >"$blocked_file"
    deny "$reason"
  fi

  rm -f "$blocked_file"

  if [ "$ADAPTER" = "plain" ] && [ -n "$output" ]; then
    printf '%s\n' "$output"
  fi

  allow
}

run_copilot_adapter() {
  local repo_hash sentinel age output
  repo_hash=$(printf '%s' "$PROJECT_ROOT" | hash_repo | cut -c1-12)
  sentinel="/tmp/.copilot-prek-recovery-${repo_hash}"

  if [ -f "$sentinel" ]; then
    age=$(($(date +%s) - $(file_mtime "$sentinel")))
    if [ "$age" -gt 600 ]; then
      rm -f "$sentinel"
    else
      if run_prek >/dev/null 2>&1; then
        rm -f "$sentinel"
      fi
      exit 0
    fi
  fi

  if ! output=$(run_prek 2>&1); then
    touch "$sentinel"
    local reason
    reason=$(failure_reason "$output")
    deny "$reason

Recovery mode enabled: subsequent tool calls will be allowed so you can fix this."
  fi

  rm -f "$sentinel"
  exit 0
}

if [ "$ADAPTER" = "copilot" ]; then
  run_copilot_adapter
else
  run_standard_adapter
fi
