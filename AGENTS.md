# AGENTS.md

## Repository Layout

* `nix/` — Nix flake configuring hosts via NixOS and nix-darwin with Home Manager
  * `flake.nix` — entrypoint; `mkNixos`/`mkDarwin` build nixosConfigurations
    (s1, s2, installer) and darwinConfigurations (d2, r2)
  * `hosts/<name>/` — per-host `configuration.nix` and `home.nix`; hosts only
    hold what differs from the shared modules
  * `hosts/installer/` — USB installer ISO (`nix build ./nix#installer-iso`,
    see `docs/installer.md`)
  * `modules/system/{linux,darwin}.nix` — shared system config per platform
  * `modules/home/{linux,darwin}.nix` — shared Home Manager config per
    platform; both import `core.nix` (packages, programs, shell)
  * `modules/home/neovim.nix`, `vscode.nix`, `s1-tools.nix`,
    `darwin-rclone.nix` — Home Manager feature modules; large config files
    live alongside in `neovim/` and `vscode/`
  * `lib/ssh-keys.nix` — SSH public keys for Linux hosts and the installer
  * `pkgs/` — local package definitions
  * `scripts/bump-deps-pr.sh` — `nix flake update` and open a PR (`uu` alias)
* `scripts/` — self-contained Python scripts with their own dev shell (see
  `scripts/AGENTS.md`)
* `fcos/` — Fedora CoreOS Ignition config (converted to JSON via `butane`)
* `docs/` — design notes and how-tos
* `.pre-commit-config.yaml` — the validation config every hook runs
* `.hooks/prek-lint.sh` — shared agent hook runner; its header documents each
  agent adapter (`.claude/`, `.codex/`, `.antigravitycli/`, `.github/hooks/`)
* `.hooks/nix-devshell.sh` — runs a command in the `nix/` dev shell without
  nesting `nix develop`
* `tests/test-prek-lint.sh` — tests for the hook runner; run it after changing
  anything in `.hooks/`

## Validation

`.pre-commit-config.yaml` is the single source of truth for validation: Nix
formatting (Alejandra), `nix flake check`, `statix`, `deadnix`, and Ruff/MyPy
for `scripts/`. Run it from the repo root after changing anything:

```bash
nix develop ./nix -c prek run --all-files
```

To format Nix files on their own, run `nix fmt` from `nix/` (pinned by
`flake.lock`). `nix flake check` is the primary test — it confirms every host configuration
evaluates, including the Darwin hosts (via `checks.<system>.darwin-*-eval`,
since `nix flake check` otherwise skips `darwinConfigurations`). The git pre-commit hook and the Claude, Codex, Antigravity and
Copilot hooks all run the same Prek config via `.hooks/prek-lint.sh`. Treat
hook failures as a backstop: continue the turn, fix the reported issue, and do
not commit until Prek passes.

## Git Repo

* Commits use a "conventional commits" style
* This repo has a long history but none of the history is relevant to an
  agent at this point. The repo underwent a large shift in structure at tag
  v0.5.0 and anything before then should be ignored.

## Keeping AGENTS.md Up To Date

Propose edits to this file to keep it updated. For example when i repeatedly
correct an agent or share significant info about how to work in this repo
