{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homeNetwork.vscode;
  configuredVscodeCli =
    if cfg.cliPath == null
    then ""
    else cfg.cliPath;
  vscodeUserDir =
    if pkgs.stdenv.isDarwin
    then "Library/Application Support/Code/User"
    else ".config/Code/User";

  settingsJson = builtins.readFile ./vscode/settings.json;
  keybindingsJson = builtins.readFile ./vscode/keybindings.json;
  mcpJson = builtins.readFile ./vscode/mcp.json;
  extensionsList = builtins.readFile ./vscode/extensions.txt;
in {
  options.homeNetwork.vscode.cliPath = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default =
      if pkgs.stdenv.isDarwin
      then "/opt/homebrew/bin/code"
      else null;
    description = ''
      Path to the VS Code CLI used for extension sync during Home Manager
      activation. When this path is unset or unavailable, the activation hook
      falls back to resolving `code` from PATH.
    '';
  };

  config = {
    home.file = {
      "${vscodeUserDir}/settings.json".text = settingsJson;
      "${vscodeUserDir}/keybindings.json".text = keybindingsJson;
      "${vscodeUserDir}/mcp.json".text = mcpJson;
    };

    home.activation.installMissingVscodeExtensions = lib.hm.dag.entryAfter ["writeBoundary"] ''
      configured_vscode_cli=${lib.escapeShellArg configuredVscodeCli}
      vscode_cli=""

      if [ -n "$configured_vscode_cli" ] && [ -x "$configured_vscode_cli" ]; then
        vscode_cli="$configured_vscode_cli"
      elif command -v code >/dev/null 2>&1; then
        vscode_cli="$(command -v code)"
      fi

      if [ -z "$vscode_cli" ]; then
        if [ -n "$configured_vscode_cli" ]; then
          echo "VS Code CLI not found at $configured_vscode_cli and 'code' is not on PATH; skipping VS Code extension sync." >&2
        else
          echo "VS Code CLI 'code' not found on PATH; skipping VS Code extension sync." >&2
        fi
      else
        installed_extensions="$("$vscode_cli" --list-extensions)"

        while IFS= read -r extension || [ -n "$extension" ]; do
          case "$extension" in
            ""|\#*)
              continue
              ;;
          esac

          if ! printf '%s\n' "$installed_extensions" | grep -Fxq -- "$extension"; then
            echo "Installing VS Code extension: $extension"
            "$vscode_cli" --install-extension "$extension"
          fi
        done <<< ${lib.escapeShellArg extensionsList}
      fi
    '';
  };
}
