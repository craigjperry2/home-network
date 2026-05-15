# Gemini CLI Mandates

You are operating in a Nix-heavy infrastructure-as-code repository. Precision and validation are your highest priorities.

## Repository Architecture
- **Nix Flake:** Rooted in `nix/`. All Nix commands MUST be run from this directory.
- **Hosts:** Defined in `nix/hosts/`. Modules are shared across macOS (`darwin`) and Linux (`nixos`).
- **Hooks:** Located in `.gemini/hooks/`. Validation is automated.

## Critical Workflows

### 1. Nix Modifications
Every turn that modifies `.nix` or `flake.lock` files MUST be followed by:
1. `cd nix`
2. `nix run nixpkgs#alejandra -- .` (Formatting)
3. `nix flake check` (Evaluation)
4. `nix develop -c statix check` (Linting)
5. `nix develop -c deadnix --fail` (Unused code)

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
