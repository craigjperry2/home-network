#!/usr/bin/env bash
set -e

# Detect if nix files were changed in the workspace (including staged and untracked)
NIX_CHANGES=$(git status --porcelain | awk '{print $2}' | grep -E '\.nix$|flake\.lock$' || true)

if [ -n "$NIX_CHANGES" ]; then
  # Navigate to the nix directory
  PROJECT_ROOT="${GEMINI_PROJECT_DIR:-$(pwd)}"
  cd "$PROJECT_ROOT/nix" || { echo '{"decision": "block", "reason": "Could not find nix directory"}'; exit 0; }

  # 1. Format
  if ! nix run nixpkgs#alejandra -- . >/dev/null 2>&1; then
    echo '{"decision": "block", "reason": "Nix formatting (alejandra) failed. Run: cd nix && nix run nixpkgs#alejandra -- ."}'
    exit 0
  fi

  # 2. Evaluate
  if ! nix flake check --extra-experimental-features "nix-command flakes" >/dev/null 2>&1; then
    echo '{"decision": "block", "reason": "Nix flake check failed. The configuration does not evaluate correctly. Check nix/flake.nix"}'
    exit 0
  fi

  # 3. Lint (Statix)
  if ! nix develop -c statix check >/dev/null 2>&1; then
    echo '{"decision": "block", "reason": "Nix lint (statix) failed. Please address the linting warnings/errors."}'
    exit 0
  fi

  # 4. Lint (Deadnix)
  if ! nix develop -c deadnix --fail >/dev/null 2>&1; then
    echo '{"decision": "block", "reason": "Nix lint (deadnix) failed. Please remove unused code."}'
    exit 0
  fi
fi

echo '{"decision": "allow"}'
exit 0
