#!/usr/bin/env bash
set -euo pipefail

# Stop hooks must emit JSON on stdout. Keep human-readable details in the
# decision reason so Codex can continue with concrete repair instructions.
json_escape() {
  local value=${1-}
  value=${value//\\/\\\\}
  value=${value//\"/\\\"}
  value=${value//$'\n'/\\n}
  value=${value//$'\r'/}
  value=${value//$'\t'/\\t}
  printf '%s' "$value"
}

block() {
  local reason=$1
  printf '{"decision":"block","reason":"%s"}\n' "$(json_escape "$reason")"
  exit 0
}

PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

if [ ! -d "$PROJECT_ROOT/nix" ]; then
  block "Codex Nix validation could not find $PROJECT_ROOT/nix."
fi

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

if [ ${#changed_files[@]} -eq 0 ]; then
  printf '{}\n'
  exit 0
fi

if ! output=$(cd "$PROJECT_ROOT" && nix develop ./nix -c prek run --files "${changed_files[@]}" 2>&1); then
  block "Prek Nix validation failed.

Run from the repo root: nix develop ./nix -c prek run --files ${changed_files[*]}

Output:
$output"
fi

printf '{}\n'
