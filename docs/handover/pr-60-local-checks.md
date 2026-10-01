# Handover: run PR #60's checks on a real machine

PR: https://github.com/craigjperry2/home-network/pull/60
Branch: `claude/jolly-wozniak-ockl2b` (base `main`)

You are picking up a PR that was written in a cloud sandbox that **could not
download the flake inputs** (GitHub tarballs were blocked). So `nix flake
check`, statix, deadnix, Alejandra and every build have **never run** against
this branch. Your job is to run them on the owner's machine, fix what breaks,
and report back. Read `AGENTS.md` first; it already reflects this branch.

## What the PR changed (one commit each)

| # | Commit subject (abridged) | Main files |
|---|---|---|
| 9 | drop committed Antigravity project symlink | `.gitignore` |
| 2 | surface Claude Stop-hook failures, loop guard | `.hooks/prek-lint.sh`, `tests/test-prek-lint.sh` |
| 4 | 600s timeout on every agent hook | `.claude/`, `.antigravitycli/`, `.github/hooks/` |
| 5 | skip Prek when state already passed | `.hooks/prek-lint.sh` (state in `.git/prek-hook/`) |
| 7 | one file filter, one validation command | `.hooks/prek-lint.sh`, `nix/scripts/bump-deps-pr.sh` |
| 10 | pin formatter, no nested `nix develop` | `nix/flake.nix`, `.hooks/nix-devshell.sh`, `.pre-commit-config.yaml` |
| 1 | `nix flake check` evaluates Darwin hosts | `nix/flake.nix` (`checks.<system>.darwin-*-eval`) |
| 12 | `mkNixos`/`mkDarwin` helpers | `nix/flake.nix`, `nix/hosts/*/configuration.nix` |
| 13 | per-platform Home Manager modules | `nix/modules/home/{linux,darwin}.nix`, `nix/hosts/*/home.nix` |
| 14 | CUDA only in s1's unstable set | `nix/flake.nix` |
| 16 | Neovim out of `core.nix` | `nix/modules/home/neovim.nix`, `nix/modules/home/neovim/` |
| 17 | installer ISO from the flake | `nix/hosts/installer/`, `nix/lib/ssh-keys.nix`, `docs/installer.md` |
| 18 | key-only SSH on Linux hosts | `nix/modules/system/linux.nix` |
| 19 | s1 firewall matches listeners | `nix/hosts/s1/configuration.nix` |
| 20 | `srp`/`why-awake` as shellchecked scripts | `nix/modules/home/s1-tools.nix` |
| 21 | broken alias / bookmark fixes | `nix/modules/home/core.nix` |
| 23 | GC + store optimise on Macs | `nix/modules/system/darwin.nix` |
| 8 | docs consolidation | `AGENTS.md`, `README.md`, `ANTIGRAVITY.md` |

Already verified in the sandbox: hook tests pass, every `.nix` file parses,
host module wiring matches `main` (with stubbed inputs), the darwin-eval
check pattern fails on a broken config, and `srp` output matches the old
alias.

## Ground rules

- **Build, never activate.** Do not run `darwin-rebuild switch`,
  `nixos-rebuild switch`/`test`/`boot`, or `uu`/`sns`. Activating is the
  owner's call, especially #18 (SSH lockout risk, see below).
- Do not run `nix/scripts/bump-deps-pr.sh`; it pushes a branch and opens a PR.
- Do not run `nix flake update`; validate against the committed `flake.lock`.
- Fix forward with small conventional commits on this branch. Never rebase,
  amend or force-push; it is a shared PR branch.
- Do not reverse the judgement calls listed under "Decisions" without asking.
- If a fix needs a design change (for example dropping a whole item), stop and
  ask the owner instead.

## Where to run what

| Check | Mac (d2 or r2) | s1 (x86_64 NixOS) |
|---|---|---|
| Steps 1–4 (Prek, flake check, hooks) | yes | yes, also proves the Darwin eval works from Linux |
| Step 5 build | `darwin-rebuild build` for the Mac you are on | `nixos-rebuild build` for s1 |
| Step 6 ISO | skip unless a Linux builder is set up | yes |

One machine is enough to start. Prefer the Mac, then repeat steps 2 and 5 on
s1 if you can reach it.

## Steps

### 0. Check out

```bash
cd ~/Code/github.com/craigjperry2/home-network
git status            # must be clean; if not, stop and ask
git fetch origin claude/jolly-wozniak-ockl2b
git switch claude/jolly-wozniak-ockl2b
git pull --ff-only
```

### 1. Full validation (the main check)

```bash
nix develop ./nix -c prek run --all-files
```

Expected: every hook passes. Likely first-run outcome: **`Format Nix files`
fails because Alejandra reformatted files.** The sandbox matched Alejandra's
style by hand, mainly in `nix/flake.nix` (`checks`, `formatter`,
`nixosConfigurations`). That is expected: review the diff (whitespace and
layout only), commit it as `style(nix): apply alejandra`, and re-run until
clean.

### 2. If `nix flake check` fails

Re-run it alone for a full trace:

```bash
cd nix && nix flake check --show-trace
```

Known risk points, most likely first:

1. **`darwin-*-eval` checks fail when evaluated on Linux** (s1), for example
   import-from-derivation or a Darwin-only `throw`. Fix: keep the checks but
   generate them only for `aarch64-darwin`, e.g. `checks.aarch64-darwin = …`
   instead of `eachSystem`, and update the comment in `flake.nix` and the
   AGENTS.md sentence about it. Keep them on the Mac either way; that is the
   point of #1.
2. **Home Manager `users.craig.imports = [platformHome homeFile]`** (#13).
   If HM rejects it, use `users.craig = {imports = [platformHome homeFile];};`.
3. **`nix.gc.interval` / `nix.optimise.automatic` on Darwin** (#23). These
   assert `nix.enable = true` (the nix-darwin default). If evaluation reports
   that nix is unmanaged, stop and ask the owner. Do not just delete #23.
4. **`services.immich.openFirewall`** (#19). If the option is unknown in this
   nixpkgs, restore `networking.firewall.allowedTCPPorts = [2283];` in
   `nix/hosts/s1/configuration.nix`.
5. **Installer** (#17): `nixosConfigurations.installer` imports
   `installation-cd-minimal.nix` via `modulesPath`. Fix any path error there.

### 3. statix / deadnix failures

Fix what they report. Likely candidates: repeated top-level keys in a module
(merge them into one attrset) or an unused lambda argument (replace with `_`
or drop it from the `{ … }` pattern).

### 4. Hook and tooling smoke tests

```bash
bash tests/test-prek-lint.sh                      # expect: ok
nix develop ./nix -c sh -c 'echo $HOME_NETWORK_DEVSHELL; command -v alejandra'
                                                  # expect: 1 and a /nix/store path
(cd nix && timeout 60 nix fmt) && git status --short  # must not hang; expect no changes after step 1
```

Claude hook end to end (#2). Break formatting on purpose, confirm the block
carries the reason, then revert:

```bash
printf '{ a=1; }\n' > nix/zz-tmp.nix
bash .hooks/prek-lint.sh --adapter claude <<<'{"stop_hook_active": false}'
# expect a single line of JSON: {"decision":"block","reason":"Prek validation failed. ..."}
rm nix/zz-tmp.nix
```

### 5. Build the system closures (no activation)

`nix flake check` only evaluates. Shellcheck for `srp`/`why-awake` (#20)
runs only at **build** time, and so do the local packages.

```bash
# On a Mac (use the host you are on: d2 or r2)
darwin-rebuild build --flake ./nix#$(hostname -s)

# On s1
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

### 6. Installer ISO (s1 only, optional)

```bash
nix build ./nix#installer-iso && ls result/iso/
```

## Decisions to leave alone unless the owner says otherwise

- **#19**: llama-server stays on `127.0.0.1` with 11434 closed. If the owner
  wants remote access, change `--host` and reopen the port.
- **#21**: the nnn `d` bookmark now points at the dotfiles checkout, the same
  path as the `cdd` alias.
- **#7**: `bump-deps-pr.sh` now runs all Prek hooks, including the Python ones,
  which download packages via `uv`.

## Before the owner switches s1 (tell them this)

#18 disables SSH password and keyboard-interactive login and root login on
Linux hosts. Before `sns` on s1, the owner should confirm they can log in
with a key listed in `nix/lib/ssh-keys.nix` (`ssh -o PreferredAuthentications=publickey s1…`)
and keep an existing session open while switching.

## Finish

1. Push your fix commits: `git push origin claude/jolly-wozniak-ockl2b`.
2. Delete this file in a final commit (`chore: remove PR #60 handover`). It
   must not land on `main`.
3. Comment on PR #60 with:
   - the machine(s) used and `nix --version`
   - a pass/fail line for each of steps 1–6, with the exact error for any
     failure you could not fix
   - each fix commit and why it was needed
   - anything you stopped to ask about
