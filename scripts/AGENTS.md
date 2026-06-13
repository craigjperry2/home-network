# Scripts

Self-contained python scripts, intended to be run via `uv run` in an ephemeral
venv with dependencies declared inline in the script header.

## Python Standards

- Ensure all scripts pass `ruff check`, `ruff format` and `mypy`.
- Use `uv run` for execution to handle inline dependencies.
- Run checks manually with `nix develop ./scripts -c ruff check .`, `nix develop ./scripts -c ruff format .` and `nix develop ./scripts -c uv run --with-requirements <script_name>.py python -m mypy <script_name>.py`.

