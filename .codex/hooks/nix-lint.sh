#!/usr/bin/env bash
set -euo pipefail

NIX_CHANGES=$(git diff --name-only HEAD | grep -E '\.nix$|flake\.lock$' || true)

if [ -n "$NIX_CHANGES" ]; then
  PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

  cd "$PROJECT_ROOT/nix" || exit 1

  if ! nix run nixpkgs#alejandra -- . >/dev/null 2>&1; then
    echo '{"decision":"block","reason":"Nix formatting (alejandra) failed. Please fix formatting."}'
    exit 0
  fi

  if ! nix flake check >/dev/null 2>&1; then
    echo '{"decision":"block","reason":"Nix flake check failed. The configuration does not evaluate correctly."}'
    exit 0
  fi

  if ! nix develop -c statix check >/dev/null 2>&1; then
    echo '{"decision":"block","reason":"Nix lint (statix) failed. Please address the linting warnings/errors."}'
    exit 0
  fi

  if ! nix develop -c deadnix >/dev/null 2>&1; then
    echo '{"decision":"block","reason":"Nix lint (deadnix) failed. Please remove unused code."}'
    exit 0
  fi
fi

echo '{}'
