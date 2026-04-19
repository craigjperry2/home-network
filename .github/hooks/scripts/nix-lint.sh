#!/bin/bash
set -euo pipefail

# Copilot hooks provide JSON on stdin, but the shared validator only needs git state.
cat >/dev/null || true

PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
RESULT="$(bash "$PROJECT_ROOT/.codex/hooks/nix-lint.sh")"

if [ "$RESULT" = "{}" ]; then
  exit 0
fi

echo "Copilot Nix validation hook failed: $RESULT" >&2
exit 1
