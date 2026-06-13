# Gemini CLI Instructions

Project-wide instructions live in `AGENTS.md`; treat that file as authoritative.

Gemini-specific notes:

* `.gemini/settings.json` runs `.hooks/prek-lint.sh --adapter gemini` after each
  turn. The shared hook runner uses `.pre-commit-config.yaml` as the canonical
  Prek validation config and translates failures into Gemini hook decisions.
* Use `save_memory` with `scope="project"` to persist host-specific quirks or
  deployment notes discovered during sessions.
