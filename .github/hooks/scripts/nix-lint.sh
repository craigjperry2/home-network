#!/usr/bin/env bash
set -euo pipefail

# Copilot hooks receive JSON on stdin with toolName, toolArgs, etc.
INPUT=$(cat || true)
readonly INPUT

json_escape() {
  local value=${1-}
  value=${value//\\/\\\\}
  value=${value//\"/\\\"}
  value=${value//$'\n'/\\n}
  value=${value//$'\r'/}
  value=${value//$'\t'/\\t}
  printf '%s' "$value"
}

deny() {
  local reason=$1
  printf '{"permissionDecision":"deny","permissionDecisionReason":"%s"}\n' "$(json_escape "$reason")"
  exit 0
}

PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

changed_files=()
while IFS= read -r file; do
  changed_files+=("$file")
done < <(
  cd "$PROJECT_ROOT"
  {
    git diff --name-only HEAD 2>/dev/null
    git ls-files --others --exclude-standard 2>/dev/null
  } | grep -E '(^|/)([^/]+\.nix|flake\.lock)$' | awk '!seen[$0]++' || true
)

REPO_HASH=$(printf '%s' "$PROJECT_ROOT" | shasum -a 256 | cut -c1-12)
SENTINEL="/tmp/.copilot-nix-recovery-${REPO_HASH}"

if [ ${#changed_files[@]} -eq 0 ]; then
  rm -f "$SENTINEL"
  exit 0
fi

run_prek() {
  cd "$PROJECT_ROOT"
  nix develop ./nix -c prek run --files "${changed_files[@]}"
}

if [ -f "$SENTINEL" ]; then
  SENTINEL_AGE=$(($(date +%s) - $(stat -f %m "$SENTINEL" 2>/dev/null || echo 0)))
  if [ "$SENTINEL_AGE" -gt 600 ]; then
    rm -f "$SENTINEL"
  else
    if run_prek >/dev/null 2>&1; then
      rm -f "$SENTINEL"
    fi
    exit 0
  fi
fi

if ! output=$(run_prek 2>&1); then
  touch "$SENTINEL"
  deny "Prek Nix validation failed.

Run from the repo root: nix develop ./nix -c prek run --files ${changed_files[*]}

Output:
$output

Recovery mode enabled: subsequent tool calls will be allowed so you can fix this."
fi

exit 0
