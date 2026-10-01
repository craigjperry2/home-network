#!/usr/bin/env bash
# Run a command from nix/ with the flake's dev shell tools on PATH. Reuses the
# current environment when it already is that dev shell (agent hooks and
# bump-deps-pr.sh run inside it), so hooks do not nest `nix develop`.
set -euo pipefail

cd "$(git rev-parse --show-toplevel)/nix"

if [ "${HOME_NETWORK_DEVSHELL-}" = 1 ]; then
  exec "$@"
fi

exec nix develop -c "$@"
