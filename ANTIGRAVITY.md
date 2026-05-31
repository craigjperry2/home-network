# Antigravity CLI Instructions

Project-wide instructions live in `AGENTS.md`; treat that file as authoritative.

Antigravity-specific notes:

* `.antigravitycli/hooks.json` runs `.hooks/nix-lint.sh --adapter antigravity` during `PostInvocation`. The shared hook runner uses `.pre-commit-config.yaml` as the canonical Prek validation config and translates failures into hook block decisions.
* Ensure you have `"enableJsonHooks": true` in your global user settings (typically `~/.gemini/antigravity-cli/settings.json`) to enable local hook execution.
