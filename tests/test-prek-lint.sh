#!/usr/bin/env bash
set -euo pipefail

repo_root=$(git rev-parse --show-toplevel)
hook_script="$repo_root/.hooks/prek-lint.sh"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_contains() {
  local haystack=$1
  local needle=$2

  if [[ "$haystack" != *"$needle"* ]]; then
    fail "expected output to contain '$needle'"
  fi
}

assert_file_contains() {
  local file=$1
  local needle=$2

  if ! grep -Fq "$needle" "$file"; then
    fail "expected $file to contain '$needle'"
  fi
}

assert_exists() {
  local path=$1

  if [ ! -e "$path" ]; then
    fail "expected $path to exist"
  fi
}

assert_not_exists() {
  local path=$1

  if [ -e "$path" ]; then
    fail "expected $path to be absent"
  fi
}

hash_repo() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256
  else
    sha256sum
  fi
}

tmpdir=$(mktemp -d)
repo="$tmpdir/repo"
stub_bin="$tmpdir/bin"
stub_log="$tmpdir/prek.log"

cleanup() {
  if [ -n "${sentinel-}" ]; then
    rm -f "$sentinel"
  fi
  rm -rf "$tmpdir"
}

trap cleanup EXIT

mkdir -p "$repo/.hooks" "$repo/scripts" "$stub_bin"
cp "$hook_script" "$repo/.hooks/prek-lint.sh"
chmod +x "$repo/.hooks/prek-lint.sh"

cat >"$stub_bin/nix" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

printf '%s\n' "$*" >>"$PREK_STUB_LOG"

checking_files=0
for arg in "$@"; do
  if [ "$checking_files" -eq 1 ] && grep -Fq 'HOOK_FAIL' "$arg"; then
    printf 'stub prek failure for %s\n' "$arg" >&2
    exit 1
  fi

  if [ "$arg" = "--files" ]; then
    checking_files=1
  fi
done
EOF
chmod +x "$stub_bin/nix"

git -C "$repo" init -q
git -C "$repo" config user.name 'Hook Test'
git -C "$repo" config user.email 'hook-test@example.com'

nix_file=flake.nix
python_file=scripts/test.py

nix_clean='{
  description = "hook test";
}
'
nix_fail='{
  description = "hook test"; HOOK_FAIL
}
'
python_clean='print("ok")
'
python_fail='print("ok")  # HOOK_FAIL
'

printf '%s' "$nix_clean" >"$repo/$nix_file"
printf '%s' "$python_clean" >"$repo/$python_file"

git -C "$repo" add "$nix_file" "$python_file"
git -C "$repo" commit -qm 'test fixtures'

repo_hash=$(printf '%s' "$repo" | hash_repo | cut -c1-12)
sentinel="/tmp/.copilot-prek-recovery-${repo_hash}"
rm -f "$sentinel"

run_hook() {
  PATH="$stub_bin:$PATH" \
  PREK_STUB_LOG="$stub_log" \
  PROJECT_ROOT="$repo" \
  bash "$repo/.hooks/prek-lint.sh" --adapter copilot </dev/null
}

exercise_case() {
  local path=$1
  local clean_contents=$2
  local failing_contents=$3

  : >"$stub_log"
  printf '%s' "$failing_contents" >"$repo/$path"

  local output
  output=$(run_hook)
  assert_contains "$output" '"permissionDecision":"deny"'
  assert_contains "$output" "$path"
  assert_contains "$output" 'Recovery mode enabled'
  assert_file_contains "$stub_log" "$path"
  assert_exists "$sentinel"

  : >"$stub_log"
  run_hook >/dev/null
  assert_file_contains "$stub_log" "$path"
  assert_exists "$sentinel"

  : >"$stub_log"
  printf '%s' "$clean_contents" >"$repo/$path"
  run_hook >/dev/null
  assert_not_exists "$sentinel"

  git -C "$repo" checkout -- "$path"
}

exercise_case "$nix_file" "$nix_clean" "$nix_fail"
exercise_case "$python_file" "$python_clean" "$python_fail"

run_antigravity_hook() {
  PATH="$stub_bin:$PATH" \
  PREK_STUB_LOG="$stub_log" \
  PROJECT_ROOT="$repo" \
  bash "$repo/.hooks/prek-lint.sh" --adapter antigravity </dev/null
}

exercise_antigravity_case() {
  local path=$1
  local clean_contents=$2
  local failing_contents=$3

  : >"$stub_log"
  printf '%s' "$failing_contents" >"$repo/$path"

  local output
  output=$(run_antigravity_hook)
  assert_contains "$output" '"decision":"block"'
  assert_contains "$output" "$path"

  printf '%s' "$clean_contents" >"$repo/$path"
  output=$(run_antigravity_hook)
  assert_contains "$output" '"decision":"allow"'

  git -C "$repo" checkout -- "$path"
}

exercise_antigravity_case "$nix_file" "$nix_clean" "$nix_fail"
exercise_antigravity_case "$python_file" "$python_clean" "$python_fail"

run_stop_hook() {
  local adapter=$1
  local payload=$2
  PATH="$stub_bin:$PATH" \
  PREK_STUB_LOG="$stub_log" \
  PROJECT_ROOT="$repo" \
  bash "$repo/.hooks/prek-lint.sh" --adapter "$adapter" <<<"$payload"
}

assert_empty() {
  if [ -n "$1" ]; then
    fail "expected no output, got '$1'"
  fi
}

exercise_stop_case() {
  local adapter=$1
  local path=$2
  local clean_contents=$3
  local failing_contents=$4
  local output errors

  printf '%s' "$failing_contents" >"$repo/$path"

  # First stop: blocked, with the failure details in the JSON reason.
  output=$(run_stop_hook "$adapter" '{"stop_hook_active": false}')
  assert_contains "$output" '"decision":"block"'
  assert_contains "$output" "$path"
  assert_contains "$output" 'stub prek failure'

  # Continuing after a block but with edits that still fail: blocked again.
  printf '%s\n' "$failing_contents" >"$repo/$path"
  output=$(run_stop_hook "$adapter" '{"stop_hook_active": true}')
  assert_contains "$output" '"decision":"block"'

  # Continuing after a block with no further edits: allowed, reason on stderr.
  errors=$(run_stop_hook "$adapter" '{"stop_hook_active": true}' 2>&1 >/dev/null)
  assert_contains "$errors" 'No changes since the last block'
  output=$(run_stop_hook "$adapter" '{"stop_hook_active": true}' 2>/dev/null)
  if [[ "$output" == *'"decision":"block"'* ]]; then
    fail "expected $adapter hook to allow when nothing changed since the last block"
  fi

  printf '%s' "$clean_contents" >"$repo/$path"
  output=$(run_stop_hook "$adapter" '{"stop_hook_active": true}')
  if [[ "$output" == *'"decision":"block"'* ]]; then
    fail "expected $adapter hook to allow once checks pass"
  fi

  git -C "$repo" checkout -- "$path"
}

exercise_stop_case claude "$nix_file" "$nix_clean" "$nix_fail"
exercise_stop_case claude "$python_file" "$python_clean" "$python_fail"
exercise_stop_case codex "$nix_file" "$nix_clean" "$nix_fail"
assert_empty "$(run_stop_hook claude '{}')"

printf 'ok\n'
