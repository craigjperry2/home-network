# Gemini CLI Mandates

You are operating in a Nix-heavy infrastructure-as-code repository. Precision and validation are your highest priorities.

## Repository Architecture
- **Nix Flake:** Rooted in `nix/`. All Nix commands MUST be run from this directory.
- **Hosts:** Defined in `nix/hosts/`. Modules are shared across macOS (`darwin`) and Linux (`nixos`).
- **Hooks:** Located in `.gemini/hooks/`. Validation is automated.

## Critical Workflows

### 1. Nix Modifications
Every turn that modifies `.nix` or `flake.lock` files MUST validate the change.
Enter the Nix dev shell once:

```bash
cd nix
nix develop
```

Then run:

```bash
nix run nixpkgs#alejandra -- .
nix flake check
statix check
deadnix --fail
```

`.pre-commit-config.yaml` is the canonical Prek hook configuration. Gemini's
hook adapter runs Prek for changed Nix files and translates failures into Gemini
hook decisions.

### 2. Commit Style
Adhere strictly to **Conventional Commits**.
- `feat(host): ...`
- `fix(nix): ...`
- `chore(deps): ...`

## Engineering Standards
- **DRY Modules:** Prefer extending `nix/modules/` over duplicating logic in `hosts/`.
- **Validation First:** Never assume a Nix change is correct until `nix flake check` passes.
- **Surgical Edits:** When updating `home.nix`, ensure you don't accidentally revert user-specific tweaks.

## Knowledge Base
- Use `save_memory` with `scope="project"` to persist host-specific quirks or deployment notes discovered during sessions.
