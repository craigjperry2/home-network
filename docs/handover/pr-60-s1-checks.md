# Handover: run PR #60's remaining checks on s1

PR: https://github.com/craigjperry2/home-network/pull/60
Branch: `claude/jolly-wozniak-ockl2b` (base `main`)

This replaces `docs/handover/pr-60-local-checks.md`, whose job (running the
PR's checks on a Mac) is done — see the results below. What's left is steps
2, 5 and (optionally) 6 on s1, x86_64 NixOS.

## Already verified, on r2 (aarch64-darwin)

- `nix develop ./nix -c prek run --all-files`: every Nix hook passes
  (Alejandra, `nix flake check`, statix, deadnix). `python-mypy` fails with
  `ModuleNotFoundError: No module named 'librt.base64'` — a broken
  `mypy`/`librt` pairing in the pinned nixpkgs that also reproduces on
  `main`, so it's unrelated to this PR and out of scope here.
- `nix flake check --show-trace`: passes. `darwin-*-eval` checks are now
  generated only for `aarch64-darwin` (commit #1), so running flake check on
  s1 will **not** re-exercise those checks — that's expected, not a
  regression.
- Hook smoke tests: `tests/test-prek-lint.sh`, the devshell env var/alejandra
  check, and `nix fmt` idempotency all pass. The Claude Stop-hook
  end-to-end block path was confirmed: staging a badly-formatted file
  (`git add`) and running `.hooks/prek-lint.sh --adapter claude` produces
  the expected `{"decision":"block","reason":"Prek validation failed..."}`.
  Note: an **unstaged** new `.nix` file with bad formatting gets silently
  auto-fixed by Alejandra instead of blocking — a limitation of prek's
  tracked-files-only modification detection, not something this PR
  introduced or needs to fix.
- `darwin-rebuild build --flake ./nix#r2`: succeeds, all 25 derivations
  build clean, including the `srp`/`why-awake` shellcheck (#20).
- Fix commit already on this branch: `style(nix): apply alejandra` —
  whitespace/layout only, in `nix/modules/home/core.nix` and
  `nix/modules/home/s1-tools.nix`.

## Ground rules (still apply)

- **Build, never activate.** Do not run `nixos-rebuild switch`/`test`/`boot`
  or `sns`. Activating is the owner's call, especially #18 (SSH lockout
  risk, see below).
- Fix forward with small conventional commits on this branch. Never rebase,
  amend or force-push; it is a shared PR branch.
- Do not reverse the judgement calls under "Decisions" without asking.

## Steps still to run — on s1 (x86_64 NixOS)

### Step 2: flake check from Linux

```bash
cd nix && nix flake check --show-trace
```

Expect: all checks pass, omitting the `aarch64-darwin`-only
`darwin-*-eval` checks (see above — that's expected, not a gap).

### Step 5: build (no activation)

```bash
nixos-rebuild build --flake ./nix#s1
```

If shellcheck rejects `srp` or `why-awake`, fix the **outer** script in
`nix/modules/home/s1-tools.nix`. The heredoc bodies are remote data and are
not linted. Keep `srp`'s output format identical.

Optionally confirm s1's effective sshd config from the built closure (#18):

```bash
grep -E 'PasswordAuthentication|KbdInteractive|PermitRootLogin' result/etc/ssh/sshd_config
# expect: no / no / no
```

### Step 6 (optional): installer ISO

```bash
nix build ./nix#installer-iso && ls result/iso/
```

## Before switching s1

#18 disables SSH password and keyboard-interactive login and root login on
Linux hosts. Before `sns` on s1, confirm you can log in with a key listed in
`nix/lib/ssh-keys.nix`
(`ssh -o PreferredAuthentications=publickey s1…`) and keep an existing
session open while switching.

## Decisions to leave alone unless the owner says otherwise

- **#19**: llama-server stays on `127.0.0.1` with 11434 closed. If the owner
  wants remote access, change `--host` and reopen the port.
- **#21**: the nnn `d` bookmark now points at the dotfiles checkout, the same
  path as the `cdd` alias.
- **#7**: `bump-deps-pr.sh` now runs all Prek hooks, including the Python ones,
  which download packages via `uv`.
