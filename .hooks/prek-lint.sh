#!/usr/bin/env bash
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
  claude | plain | codex | gemini | copilot | antigravity) ;;
  *)
    printf 'Unknown Prek lint hook adapter: %s\n' "$ADAPTER" >&2
    exit 2
    ;;
esac

if [ "$ADAPTER" = "copilot" ]; then
  cat >/dev/null || true
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
    gemini | antigravity)
      printf '{"decision":"allow"}\n'
      ;;
  esac
  exit 0
}

deny() {
  local reason=$1
  case "$ADAPTER" in
    codex | gemini | antigravity)
      printf '{"decision":"block","reason":"%s"}\n' "$(json_escape "$reason")"
      exit 0
      ;;
    copilot)
      printf '{"permissionDecision":"deny","permissionDecisionReason":"%s"}\n' "$(json_escape "$reason")"
      exit 0
      ;;
    claude | plain)
      printf '%s\n' "$reason"
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
  if [ "$ADAPTER" = "gemini" ] && [ -n "${GEMINI_PROJECT_DIR-}" ]; then
    PROJECT_ROOT=$GEMINI_PROJECT_DIR
  elif [ "$ADAPTER" = "antigravity" ] && [ -n "${ANTIGRAVITY_PROJECT_DIR-}" ]; then
    PROJECT_ROOT=$ANTIGRAVITY_PROJECT_DIR
  else
    PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
  fi
fi

changed_files=()
while IFS= read -r file; do
  changed_files+=("$file")
done < <(
  cd "$PROJECT_ROOT"
  {
    git diff --name-only HEAD 2>/dev/null
    git ls-files --others --exclude-standard 2>/dev/null
  } | grep -E '((^|/)([^/]+\.nix|flake\.lock)$|^scripts/.*\.py$)' | awk '!seen[$0]++' || true
)

run_prek() {
  if [ ${#changed_files[@]} -eq 0 ]; then
    return 0
  fi

  cd "$PROJECT_ROOT"
  nix develop ./nix -c prek run --files "${changed_files[@]}"
}

failure_reason() {
  local output=$1
  printf 'Prek validation failed.\n\nRun from the repo root: nix develop ./nix -c prek run --files %s\n\nOutput:\n%s' "${changed_files[*]}" "$output"
}

run_standard_adapter() {
  local output reason
  if ! output=$(run_prek 2>&1); then
    reason=$(failure_reason "$output")
    deny "$reason"
  fi

  if { [ "$ADAPTER" = "claude" ] || [ "$ADAPTER" = "plain" ]; } && [ -n "$output" ]; then
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
