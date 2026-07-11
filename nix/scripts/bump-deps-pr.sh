#!/usr/bin/env bash
set -euo pipefail

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "missing required command: $1"
}

run() {
  printf '+'
  printf ' %q' "$@"
  printf '\n'
  "$@"
}

for cmd in git nix gh statix deadnix; do
  require_cmd "$cmd"
done

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
nix_dir=$(cd -- "$script_dir/.." && pwd -P)
repo_root=$(git -C "$nix_dir" rev-parse --show-toplevel 2>/dev/null) || die "not inside a git repository"

base_branch=${BASE_BRANCH:-main}
branch_name=${BRANCH_NAME:-feature/nix-dep-versions-bump-$(date -u +%Y%m%d%H%M%S)}
commit_message=${COMMIT_MESSAGE:-"feat(nix): deps version bump"}
pr_title=${PR_TITLE:-$commit_message}

[ "$nix_dir" = "$repo_root/nix" ] || die "script must live under the repository nix/ directory"

current_branch=$(git -C "$repo_root" branch --show-current)
[ "$current_branch" = "$base_branch" ] || die "run from $base_branch; currently on ${current_branch:-detached HEAD}"

[ -z "$(git -C "$repo_root" status --porcelain)" ] || die "working tree is not clean"

run gh auth status >/dev/null
run git -C "$repo_root" fetch origin "$base_branch"

git -C "$repo_root" rev-parse --verify "$base_branch" >/dev/null
git -C "$repo_root" rev-parse --verify "origin/$base_branch" >/dev/null

local_rev=$(git -C "$repo_root" rev-parse "$base_branch")
remote_rev=$(git -C "$repo_root" rev-parse "origin/$base_branch")
merge_base=$(git -C "$repo_root" merge-base "$base_branch" "origin/$base_branch")

if [ "$local_rev" != "$remote_rev" ]; then
  if [ "$local_rev" = "$merge_base" ]; then
    die "$base_branch is behind origin/$base_branch; run: git pull --ff-only"
  fi
  if [ "$remote_rev" = "$merge_base" ]; then
    die "$base_branch is ahead of origin/$base_branch; push or reset it before running"
  fi
  die "$base_branch and origin/$base_branch have diverged"
fi

if git -C "$repo_root" show-ref --verify --quiet "refs/heads/$branch_name"; then
  die "local branch already exists: $branch_name"
fi

if git -C "$repo_root" ls-remote --exit-code --heads origin "$branch_name" >/dev/null 2>&1; then
  die "remote branch already exists: $branch_name"
fi

run git -C "$repo_root" switch -c "$branch_name" "$base_branch"

run nix flake update --flake "$nix_dir"

changed_files=$(git -C "$repo_root" diff --name-only)
if [ -z "$changed_files" ]; then
  run git -C "$repo_root" switch "$base_branch"
  run git -C "$repo_root" branch -D "$branch_name"
  printf 'No flake input updates available.\n'
  exit 0
fi

if [ "$changed_files" != "nix/flake.lock" ]; then
  git -C "$repo_root" diff --stat
  die "expected only nix/flake.lock to change; inspect the working tree"
fi

(
  cd "$nix_dir"
  run nix run nixpkgs#alejandra -- .
  run nix flake check
  run statix check
  run deadnix --fail
)

run git -C "$repo_root" add nix/flake.lock
run git -C "$repo_root" commit -m "$commit_message"
run git -C "$repo_root" push -u origin "$branch_name"

pr_body=$(mktemp)
trap 'rm -f "$pr_body"' EXIT

cat >"$pr_body" <<'EOF'
## Summary
- Update Nix flake lock inputs via nix flake update.
- Bump nixpkgs, nix-darwin, home-manager, Homebrew sources, and Homebrew taps.

## Validation
- nix run nixpkgs#alejandra -- .
- nix flake check
- statix check
- deadnix --fail
EOF

run gh pr create --base "$base_branch" --head "$branch_name" --title "$pr_title" --body-file "$pr_body"

