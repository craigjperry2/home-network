# AGENTS.md

## Repository Layout

* `nix/` — Nix flake configuring hosts via NixOS and nix-darwin with Home Manager
  * `flake.nix` — flake entrypoint; defines nixosConfigurations (s1),
     darwinConfigurations (d2, r2)
  * `hosts/<name>/` — per-host (s1, d2, r2) `configuration.nix` and `home.nix`
  * `modules/home/core.nix` — shared Home Manager config (packages, programs, shell)
  * `modules/system/darwin.nix` — shared macOS system config
* `nix-install/` — custom NixOS installer ISO for building s1 host (legacy
   non-flake `nix-build` workflow)
* `fcos/` — Fedora CoreOS Ignition config (converted to JSON via `butane`)
* `.claude/` — repo-local Claude Code config and hooks
  * `hooks/nix-lint.sh` — formats, evaluates and lints Nix changes; exit 2 blocks stop and forces a fix turn
* `.codex/` — repo-local Codex project config and hooks
  * `config.toml` — enables project-local Codex lifecycle hooks
  * `hooks.json` — runs the Nix validation hook on Codex `Stop`
  * `hooks/nix-lint.sh` — formats, evaluates and lints Nix changes; blocks stop and forces a fix turn when validation fails or formatting changed files
* `.gemini/` — repo-local Gemini CLI config and hooks
  * `hooks/nix-lint.sh` — formats, evaluates and lints Nix changes
* `.github/hooks/` — repo-local GitHub Copilot CLI hooks
  * `nix-validation.json` — runs Nix validation on `preToolUse` to block actions until validation passes
  * `scripts/nix-lint.sh` — validates Nix formatting, flake evaluation, and linting
* `AGENTS.md` — this file
* `README.md` — human-readable version of this file with additional notes

## Nix Configuration

All nix work is done from within the `nix/` directory:

```bash
cd nix
```

**Format** (alejandra):
```bash
nix run nixpkgs#alejandra -- .
```

> Note: `nix fmt` hangs waiting for stdin — use the `nix run` form above instead.

**Validate** the flake (evaluates all host configurations):
```bash
nix flake check
```

**Lint** for anti-patterns (statix) and unused code (deadnix):
```bash
nix develop -c statix check
nix develop -c deadnix --fail
```

Always run `nix run nixpkgs#alejandra -- .` and `nix flake check` after making changes to nix files.
`nix flake check` is the primary test — it confirms the full configuration evaluates without errors.
Before committing Nix changes, also run the full lint sequence:

```bash
nix develop -c statix check
nix develop -c deadnix --fail
```

Codex has a project-local Stop hook that runs the same format, flake check and
lint sequence whenever `.nix` files or `flake.lock` are changed, including
untracked files. Treat this hook as a backstop: if it blocks, continue the turn,
fix the reported issue, and do not commit until the hook or explicit validation
passes.

Claude, Codex, Gemini and Copilot are configured in this repo to run the same Nix validation sequence automatically after turns that modify `.nix` files or `flake.lock`.

## Git Repo

* Commits use a "conventional commits" style
* This repo has a long history but none of the history is relevant to an
  agent at this point. The repo underwent a large shift in structure at tag
  v0.5.0 and anything before then should be ignored.

## Keeping AGENTS.md Up To Date

Propose edits to this file to keep it updated. For example when i repeatedly
correct an agent or share significant info about how to work in this repo
