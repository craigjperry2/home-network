#!/bin/bash
set -euo pipefail

# Copilot hooks receive JSON on stdin with toolName, toolArgs, etc.
INPUT=$(cat || true)

# Check for uncommitted nix file changes
NIX_CHANGES=$(git diff --name-only HEAD 2>/dev/null | grep -E '\.nix$|flake\.lock$' || true)

PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

# Sentinel file for recovery mode (keyed per-repo to avoid cross-repo interference)
REPO_HASH=$(echo "$PROJECT_ROOT" | shasum -a 256 | cut -c1-12)
SENTINEL="/tmp/.copilot-nix-recovery-${REPO_HASH}"

# No nix changes = allow all tools (and clean up any stale sentinel)
if [ -z "$NIX_CHANGES" ]; then
  rm -f "$SENTINEL"
  exit 0
fi

# Recovery mode: if sentinel exists, allow tools so the agent can fix the issue
if [ -f "$SENTINEL" ]; then
  # TTL: if sentinel is older than 10 minutes, expire it and re-enforce
  SENTINEL_AGE=$(( $(date +%s) - $(stat -f %m "$SENTINEL" 2>/dev/null || echo 0) ))
  if [ "$SENTINEL_AGE" -gt 600 ]; then
    rm -f "$SENTINEL"
    # Fall through to normal validation below
  else
    # Re-run validation to check if the agent has fixed the issue
    cd "$PROJECT_ROOT/nix" || exit 1
    if nix run nixpkgs#alejandra -- --check . >/dev/null 2>&1 && \
       nix flake check >/dev/null 2>&1; then
      # Fixed! Remove sentinel and return to normal enforcement
      rm -f "$SENTINEL"
    fi
    # Allow the tool regardless (agent is in recovery mode)
    exit 0
  fi
fi

cd "$PROJECT_ROOT/nix" || exit 1

# --- Normal validation ---

# 1. Format check
if ! nix run nixpkgs#alejandra -- --check . >/dev/null 2>&1; then
  touch "$SENTINEL"
  echo '{"permissionDecision":"deny","permissionDecisionReason":"Nix formatting (alejandra) failed. Run: cd nix && nix run nixpkgs#alejandra -- . — Recovery mode enabled: subsequent tool calls will be allowed so you can fix this."}'
  exit 0
fi

# 2. Flake evaluation
if ! nix flake check >/dev/null 2>&1; then
  touch "$SENTINEL"
  echo '{"permissionDecision":"deny","permissionDecisionReason":"Nix flake check failed. The configuration does not evaluate correctly. Run: cd nix && nix flake check — Recovery mode enabled: subsequent tool calls will be allowed so you can fix this."}'
  exit 0
fi

# 3. Statix lint
if ! nix develop -c statix check >/dev/null 2>&1; then
  touch "$SENTINEL"
  echo '{"permissionDecision":"deny","permissionDecisionReason":"Nix lint (statix) failed. Run: cd nix && nix develop -c statix check — Recovery mode enabled: subsequent tool calls will be allowed so you can fix this."}'
  exit 0
fi

# 4. Deadnix lint
if ! nix develop -c deadnix >/dev/null 2>&1; then
  touch "$SENTINEL"
  echo '{"permissionDecision":"deny","permissionDecisionReason":"Nix lint (deadnix) failed. Run: cd nix && nix develop -c deadnix — Recovery mode enabled: subsequent tool calls will be allowed so you can fix this."}'
  exit 0
fi

# All checks passed - allow the tool
exit 0
