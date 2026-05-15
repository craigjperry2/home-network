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

NIX_CHANGES=$(
  cd "$PROJECT_ROOT"
  {
    git diff --name-only HEAD 2>/dev/null
    git ls-files --others --exclude-standard 2>/dev/null
  } | grep -E '(^|/)([^/]+\.nix|flake\.lock)$' || true
)

if [ -z "$NIX_CHANGES" ]; then
  printf '{}\n'
  exit 0
fi

STATUS_BEFORE=$(cd "$PROJECT_ROOT" && git status --porcelain -- nix '*.nix' 'flake.lock')

run_check() {
  local label=$1
  local fix=$2
  shift 2

  local output
  if ! output=$("$@" 2>&1); then
    block "$label failed.

Run: $fix

Output:
$output"
  fi
}

cd "$PROJECT_ROOT/nix" || block "Codex Nix validation could not cd into $PROJECT_ROOT/nix."

run_check \
  "Nix formatting (alejandra)" \
  "cd nix && nix run nixpkgs#alejandra -- ." \
  nix run nixpkgs#alejandra -- .

STATUS_AFTER_FORMAT=$(cd "$PROJECT_ROOT" && git status --porcelain -- nix '*.nix' 'flake.lock')

run_check \
  "Nix flake check" \
  "cd nix && nix flake check" \
  nix flake check

run_check \
  "Nix lint (statix)" \
  "cd nix && nix develop -c statix check" \
  nix develop -c statix check

run_check \
  "Nix lint (deadnix)" \
  "cd nix && nix develop -c deadnix --fail" \
  nix develop -c deadnix --fail

if [ "$STATUS_BEFORE" != "$STATUS_AFTER_FORMAT" ]; then
  block "Alejandra formatted Nix files during the Stop hook. Review the formatter changes, then finish the turn with the validation status."
fi

printf '{}\n'
