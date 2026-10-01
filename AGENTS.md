# AGENTS.md

## Repository Layout

* `nix/` — Nix flake configuring hosts via NixOS and nix-darwin with Home Manager
  * `flake.nix` — flake entrypoint; defines nixosConfigurations (s1, s2),
    darwinConfigurations (d2, r2)
  * `hosts/<name>/` — per-host (s1, s2, d2, r2) `configuration.nix` and `home.nix`
  * `modules/home/core.nix` — shared Home Manager config (packages, programs, shell)
  * `modules/system/darwin.nix` — shared macOS system config
* `nix-install/` — custom NixOS installer ISO for building s1 host (legacy
   non-flake `nix-build` workflow)
* `fcos/` — Fedora CoreOS Ignition config (converted to JSON via `butane`)
* `.pre-commit-config.yaml` — canonical Prek git/agent hook config for Nix and Python validation
* `.hooks/prek-lint.sh` — shared hook runner that invokes Prek for changed Nix and Python files
* `.claude/` — repo-local Claude Code hook config
* `.codex/` — repo-local Codex project config and hooks
  * `config.toml` — enables project-local Codex lifecycle hooks
  * `hooks.json` — runs the shared Prek validation hook on Codex `Stop`
* `.antigravitycli/` — repo-local Antigravity CLI workspace config and hooks
  * `hooks.json` — runs the shared Prek validation hook on Antigravity `PostInvocation`
* `.github/hooks/` — repo-local GitHub Copilot CLI hooks
  * `prek-validation.json` — runs the shared Prek validation hook on `preToolUse` for changed Nix and Python files
* `AGENTS.md` — this file
* `README.md` — human-readable version of this file with additional notes

## Validation

`.pre-commit-config.yaml` is the single source of truth for validation: Nix
formatting (Alejandra), `nix flake check`, `statix`, `deadnix`, and Ruff/MyPy
for `scripts/`. Run it from the repo root after changing anything:

```bash
nix develop ./nix -c prek run --all-files
```

`nix flake check` is the primary test — it confirms every host configuration
evaluates. The git pre-commit hook and the Claude, Codex, Antigravity and
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
