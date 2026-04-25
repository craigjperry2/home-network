#!/usr/bin/env bash
set -e

# Detect if nix files were changed in the workspace
# We check the git diff for modified nix files
NIX_CHANGES=$(git diff --name-only HEAD | grep -E '\.nix$|flake\.lock$' || true)

if [ -n "$NIX_CHANGES" ]; then
  # Navigate to the nix directory
  PROJECT_ROOT="${GEMINI_PROJECT_DIR:-$(pwd)}"
  cd "$PROJECT_ROOT/nix" || { exit 1; }

  # 1. Format
  if ! nix run nixpkgs#alejandra -- . >/dev/null 2>&1; then
    echo '{"decision": "block", "reason": "Nix formatting (alejandra) failed. Please fix formatting."}'
    exit 0
  fi

  # 2. Evaluate
  if ! nix flake check >/dev/null 2>&1; then
    echo '{"decision": "block", "reason": "Nix flake check failed. The configuration does not evaluate correctly."}'
    exit 0
  fi

  # 3. Lint (Statix)
  if ! nix develop -c statix check >/dev/null 2>&1; then
    echo '{"decision": "block", "reason": "Nix lint (statix) failed. Please address the linting warnings/errors."}'
    exit 0
  fi

  # 4. Lint (Deadnix)
  if ! nix develop -c deadnix >/dev/null 2>&1; then
    echo '{"decision": "block", "reason": "Nix lint (deadnix) failed. Please remove unused code."}'
    exit 0
  fi
fi

# Always allow if everything passes or no changes
echo '{"decision": "allow"}'
exit 0
