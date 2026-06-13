# Copilot Instructions

## Prek Validation Hook

After modifying `.nix` files, `flake.lock`, or `.py` files in `scripts/`, end
your turn with a trivial tool call (e.g., `view` a file) to trigger the
`preToolUse` validation hook. The shared hook runner `.hooks/prek-lint.sh` runs
`prek` for all changed files, using `.pre-commit-config.yaml` as the canonical
validation config.

## Hook Recovery Protocol

The Copilot adapter in `.hooks/prek-lint.sh` uses a **sentinel-based recovery
mode** to avoid deadlocks:

1. **First failure**: The hook denies the tool call and reports the error. A recovery
   sentinel file is created automatically.
2. **Subsequent calls** (while sentinel exists): Tools are **allowed** so you can
   fix the issue. Use `bash` to run the suggested Prek command or `edit` to
   correct the source.
3. **After fixing**: The hook re-validates on each call. Once checks pass, the
   sentinel is removed and normal enforcement resumes.
4. **Timeout**: The sentinel expires after 10 minutes to prevent permanent bypass.

When you see a hook denial message, your next tool call will be allowed — use it to
fix the reported problem immediately.
