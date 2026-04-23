#!/bin/bash
set -euo pipefail

NIX_CHANGES=$(git diff --name-only HEAD | grep -E '\.nix$|flake\.lock$' || true)

if [ -z "$NIX_CHANGES" ]; then
  exit 0
fi

PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

cd "$PROJECT_ROOT/nix" || exit 1

if ! nix run nixpkgs#alejandra -- . >/dev/null 2>&1; then
  echo "Nix formatting (alejandra) failed. Run: cd nix && nix run nixpkgs#alejandra -- ."
  exit 2
fi

if ! nix flake check >/dev/null 2>&1; then
  echo "Nix flake check failed. Run: cd nix && nix flake check"
  exit 2
fi

if ! nix develop -c statix check >/dev/null 2>&1; then
  echo "Nix lint (statix) failed. Run: cd nix && nix develop -c statix check"
  exit 2
fi

if ! nix develop -c deadnix >/dev/null 2>&1; then
  echo "Nix lint (deadnix) failed. Run: cd nix && nix develop -c deadnix"
  exit 2
fi
