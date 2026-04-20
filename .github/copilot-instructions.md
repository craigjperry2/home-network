# Copilot Instructions

## Nix Validation Hook

After modifying `.nix` files or `flake.lock`, end your turn with a trivial tool call (e.g., `view` a file) to trigger the `preToolUse` validation hook. This ensures formatting and evaluation errors are caught before proceeding.

## Nix Hook Recovery Protocol

The `preToolUse` hook uses a **sentinel-based recovery mode** to avoid deadlocks:

1. **First failure**: The hook denies the tool call and reports the error. A recovery
   sentinel file is created automatically.
2. **Subsequent calls** (while sentinel exists): Tools are **allowed** so you can
   fix the issue. Use `bash` to run the suggested fix command (e.g.,
   `cd nix && nix run nixpkgs#alejandra -- .`) or `edit` to correct the Nix source.
3. **After fixing**: The hook re-validates on each call. Once checks pass, the
   sentinel is removed and normal enforcement resumes.
4. **Timeout**: The sentinel expires after 10 minutes to prevent permanent bypass.

When you see a hook denial message, your next tool call will be allowed — use it to
fix the reported problem immediately.
