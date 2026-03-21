# AGENTS.md

## Repository Layout

* `nix/` — Nix flake configuring 3 hosts via NixOS and nix-darwin with Home Manager
  * `flake.nix` — flake entrypoint; defines nixosConfigurations (s1), darwinConfigurations (d2, r2)
  * `hosts/<name>/` — per-host `configuration.nix` and `home.nix`
  * `modules/home/core.nix` — shared Home Manager config (packages, programs, shell)
  * `modules/system/darwin.nix` — shared macOS system config
* `nix-install/` — custom NixOS installer ISO (legacy non-flake `nix-build` workflow)
* `fcos/` — Fedora CoreOS Ignition config (converted to JSON via `butane`)
* `AGENTS.md` — this file
* `README.md` — human-readable version of this file with additional notes

## Nix Configuration

All nix work is done from within the `nix/` directory:

```bash
cd nix
```

**Format** (alejandra):
```bash
nix fmt
```

**Validate** the flake (evaluates all host configurations):
```bash
nix flake check
```

**Lint** for anti-patterns (statix) and unused code (deadnix):
```bash
nix develop -c statix check
nix develop -c deadnix
```

Always run `nix fmt` and `nix flake check` after making changes to nix files.
`nix flake check` is the primary test — it confirms the full configuration evaluates without errors.

## Git Repo

* Commits use a "conventional commits" style
* This repo has a long history but none of the history is relevant to an
  agent at this point. The repo underwent a large shift in structure at tag
  v0.5.0 and anything before then should be ignored.

## Keeping AGENTS.md Up To Date

* Propose edits to this file to keep it updated. For example when i repeatedly
  correct an agent or share significant info about how to work in this repo

