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
* `.pre-commit-config.yaml` — canonical Prek git/agent hook config for Nix validation
* `.hooks/nix-lint.sh` — shared hook runner that invokes Prek for changed Nix files
* `.claude/` — repo-local Claude Code hook config
* `.codex/` — repo-local Codex project config and hooks
  * `config.toml` — enables project-local Codex lifecycle hooks
  * `hooks.json` — runs the shared Nix validation hook on Codex `Stop`
* `.gemini/` — repo-local Gemini CLI hook config
* `.github/hooks/` — repo-local GitHub Copilot CLI hooks
  * `nix-validation.json` — runs the shared Nix validation hook on `preToolUse`
* `AGENTS.md` — this file
* `README.md` — human-readable version of this file with additional notes

## Nix Configuration

All Nix work is done from within the `nix/` directory. Enter the dev shell first:

```bash
cd nix
nix develop
```

Then run the validation sequence after changing `.nix` files or `flake.lock`:

```bash
nix run nixpkgs#alejandra -- .
nix flake check
statix check
deadnix --fail
```

`nix flake check` is the primary test — it confirms the full configuration evaluates without errors.

> Note: `nix fmt` hangs waiting for stdin — use the `nix run` form above instead.

For one-shot validation without entering the shell interactively:

```bash
cd nix
nix develop -c bash -lc 'nix run nixpkgs#alejandra -- . && nix flake check && statix check && deadnix --fail'
```

`.pre-commit-config.yaml` is the canonical Prek hook configuration. The git
pre-commit hook and the Claude, Codex, Gemini and Copilot adapters all run Prek
for changed Nix files. Treat hook failures as a backstop: continue the turn, fix
the reported issue, and do not commit until Prek or explicit validation passes.

## Git Repo

* Commits use a "conventional commits" style
* This repo has a long history but none of the history is relevant to an
  agent at this point. The repo underwent a large shift in structure at tag
  v0.5.0 and anything before then should be ignored.

## Keeping AGENTS.md Up To Date

Propose edits to this file to keep it updated. For example when i repeatedly
correct an agent or share significant info about how to work in this repo
