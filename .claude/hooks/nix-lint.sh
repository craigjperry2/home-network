#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

if [ ! -d "$PROJECT_ROOT/nix" ]; then
  echo "Nix validation could not find $PROJECT_ROOT/nix."
  exit 2
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
  exit 0
fi

if ! output=$(cd "$PROJECT_ROOT" && nix develop ./nix -c prek run --files "${changed_files[@]}" 2>&1); then
  printf '%s\n' "$output"
  exit 2
fi

printf '%s\n' "$output"
