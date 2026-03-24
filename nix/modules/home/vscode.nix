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
  settingsJson = ''
    {
      "[dockercompose]": {
        "editor.insertSpaces": true,
        "editor.tabSize": 2,
        "editor.autoIndent": "advanced",
        "editor.quickSuggestions": {
          "other": true,
          "comments": false,
          "strings": true,
        },
        "editor.defaultFormatter": "redhat.vscode-yaml",
      },
      "[github-actions-workflow]": {
        "editor.defaultFormatter": "redhat.vscode-yaml",
      },
      "[html]": { "editor.defaultFormatter": "esbenp.prettier-vscode" },
      "[jsonc]": { "editor.defaultFormatter": "esbenp.prettier-vscode" },
      "[python]": {
        "editor.codeActionsOnSave": {
          "source.fixAll": "explicit",
          "source.organizeImports": "explicit",
        },
        "editor.defaultFormatter": "charliermarsh.ruff",
        "editor.formatOnSave": true,
      },
      "[typescript]": { "editor.defaultFormatter": "esbenp.prettier-vscode" },
      "[typescriptreact]": { "editor.defaultFormatter": "esbenp.prettier-vscode" },
      "accessibility.signals.chatEditModifiedFile": { "sound": "off" },
      "accessibility.signals.chatRequestSent": { "sound": "off" },
      "accessibility.signals.clear": { "sound": "off" },
      "accessibility.signals.codeActionApplied": { "sound": "off" },
      "accessibility.signals.codeActionTriggered": { "sound": "off" },
      "accessibility.signals.diffLineDeleted": { "sound": "off" },
      "accessibility.signals.diffLineInserted": { "sound": "off" },
      "accessibility.signals.diffLineModified": { "sound": "off" },
      "accessibility.signals.editsKept": { "sound": "off" },
      "accessibility.signals.editsUndone": { "sound": "off" },
      "accessibility.signals.lineHasBreakpoint": { "sound": "off" },
      "accessibility.signals.lineHasFoldedArea": { "sound": "off" },
      "accessibility.signals.lineHasInlineSuggestion": { "sound": "off" },
      "accessibility.signals.nextEditSuggestion": { "sound": "off" },
      "accessibility.signals.noInlayHints": { "sound": "off" },
      "accessibility.signals.notebookCellCompleted": { "sound": "off" },
      "accessibility.signals.notebookCellFailed": { "sound": "off" },
      "accessibility.signals.progress": { "sound": "off" },
      "accessibility.signals.terminalCommandSucceeded": { "sound": "off" },
      "accessibility.signals.terminalQuickFix": { "sound": "off" },
      "chat.agent.thinking.collapsedTools": "off",
      "chat.mcp.gallery.enabled": true,
      "chat.tools.terminal.autoApprove": {
        "ruff": true,
        "mypy": true,
        "uv": true,
        "cargo": true,
      },
      "chat.tools.terminal.simpleCollapsible": false,
      "chat.tools.urls.autoApprove": {
        "https://raw.githubusercontent.com": {
          "approveRequest": false,
          "approveResponse": true,
        },
      },
      "chat.viewSessions.orientation": "stacked",
      "editor.fontFamily": "JetBrainsMono NF",
      "editor.fontLigatures": true,
      "editor.fontSize": 13,
      "editor.quickSuggestions": { "strings": "on" },
      "editor.rulers": [80, 120],
      "explorer.confirmDelete": false,
      "files.associations": { "*.css": "tailwindcss" },
      "files.autoSave": "afterDelay",
      "git.autofetch": true,
      "git.blame.editorDecoration.enabled": true,
      "git.blame.editorDecoration.template": "''${authorName} (''${authorDateAgo}) ''${subject}",
      "git.terminalGitEditor": true,
      "github.copilot.nextEditSuggestions.enabled": true,
      "lldb.suppressUpdateNotifications": true,
      "notebook.codeActionsOnSave": {
        "notebook.source.fixAll": "explicit",
        "notebook.source.organizeImports": "explicit",
      },
      "notebook.formatOnSave.enabled": true,
      "python.analysis.inlayHints.callArgumentNames": "all",
      "python.analysis.inlayHints.functionReturnTypes": true,
      "python.analysis.languageServerMode": "full",
      "python.analysis.typeCheckingMode": "strict",
      "python.defaultInterpreterPath": "python3",
      "python.languageServer": "Pylance",
      "pgsql.connections": [
        {
          "id": "A341074D-4C67-4C77-95BD-2C5D72CAE7D5",
          "groupId": "F40134B9-E0DB-4400-AD1F-8FB51CB409FB",
          "authenticationType": "SqlLogin",
          "connectTimeout": 15,
          "applicationName": "vscode-pgsql",
          "clientEncoding": "utf8",
          "sslmode": "prefer",
          "savePassword": true,
          "server": "romantic_lehmann.orb.local",
          "user": "postgres",
          "password": "",
          "sshPassword": "",
          "profileName": "local-pgvector, <default> (postgres)",
          "expiresOn": 0,
        },
      ],
      "pgsql.serverGroups": [
        {
          "name": "Servers",
          "id": "F40134B9-E0DB-4400-AD1F-8FB51CB409FB",
          "isDefault": true,
        },
      ],
      "redhat.telemetry.enabled": false,
      "security.workspace.trust.untrustedFiles": "open",
      "terminal.integrated.copyOnSelection": true,
      "terminal.integrated.defaultLocation": "editor",
      "terminal.integrated.fontFamily": "JetBrainsMono NF",
      "terminal.integrated.fontSize": 13,
      "vim.handleKeys": {
        "<C-s>": false,
      },
      "vim.leader": "<space>",
      "vim.normalModeKeyBindings": [
        {
          "before": ["<leader>", "/"],
          "commands": ["workbench.action.findInFiles"]
        },
        {
          "before": ["<leader>", "-"],
          "commands": ["workbench.action.splitEditorDown"]
        },
        {
          "before": ["<leader>", "|"],
          "commands": ["workbench.action.splitEditorRight"]
        },
        {
          "before": ["<leader>", "b", "d"],
          "commands": ["workbench.action.closeActiveEditor"]
        },
        {
          "before": ["<leader>", "b", "l"],
          "commands": ["workbench.action.closeEditorsToTheLeft"]
        },
        {
          "before": ["<leader>", "b", "o"],
          "commands": ["workbench.action.closeOtherEditors"]
        },
        {
          "before": ["<leader>", "b", "p"],
          "commands": ["workbench.action.pinEditor"]
        },
        {
          "before": ["<leader>", "b", "r"],
          "commands": ["workbench.action.closeEditorsToTheRight"]
        },
        {
          "before": ["<leader>", "c", "a"],
          "commands": ["editor.action.quickFix"]
        },
        {
          "before": ["<leader>", "c", "o"],
          "commands": ["editor.action.organizeImports"]
        },
        {
          "before": ["<leader>", "c", "r"],
          "commands": ["editor.action.refactor"]
        },
        {
          "before": ["<leader>", "e"],
          "commands": ["workbench.view.explorer"]
        },
        {
          "before": ["<leader>", "f", "f"],
          "commands": ["workbench.action.quickOpen"]
        },
        {
          "before": ["<leader>", "f", "n"],
          "commands": ["workbench.action.files.newUntitledFile"]
        },
        {
          "before": ["<leader>", "f", "s"],
          "commands": ["workbench.action.files.save"]
        },
        {
          "before": ["<leader>", "f", "t"],
          "commands": ["workbench.action.createTerminalEditor"]
        },
        {
          "before": ["<leader>", "u", "w"],
          "commands": ["editor.action.toggleWordWrap"]
        },
        {
          "before": ["<leader>", "x", "x"],
          "commands": ["workbench.actions.view.problems"]
        },
        {
          "before": ["<C-h>"],
          "commands": ["workbench.action.focusLeftGroup"]
        },
        {
          "before": ["<C-j>"],
          "commands": ["workbench.action.focusBelowGroup"]
        },
        {
          "before": ["<C-k>"],
          "commands": ["workbench.action.focusAboveGroup"]
        },
        {
          "before": ["<C-l>"],
          "commands": ["workbench.action.focusRightGroup"]
        },
        {
          "before": ["<S-h>"],
          "commands": ["workbench.action.previousEditor"]
        },
        {
          "before": ["<S-l>"],
          "commands": ["workbench.action.nextEditor"]
        },
        {
          "before": ["K"],
          "commands": ["editor.action.showHover"]
        },
        {
          "before": ["g", "d"],
          "commands": ["editor.action.goToDefinition"]
        },
        {
          "before": ["g", "D"],
          "commands": ["editor.action.goToDeclaration"]
        },
        {
          "before": ["g", "l"],
          "commands": ["workbench.view.scm"]
        },
        {
          "before": ["g", "I"],
          "commands": ["editor.action.goToImplementation"]
        },
        {
          "before": ["g", "r"],
          "commands": ["editor.action.goToReferences"]
        },
        {
          "before": ["g", "y"],
          "commands": ["editor.action.goToTypeDefinition"]
        },
        {
          "before": ["[", "q"],
          "commands": ["editor.action.marker.next"]
        },
        {
          "before": ["]", "q"],
          "commands": ["editor.action.marker.prev"]
        },
      ],
      "vim.smartRelativeLine": true,
      "vim.sneak": true,
      "vim.useSystemClipboard": true,
      "vsicons.dontShowNewVersionMessage": true,
      "window.autoDetectColorScheme": false,
      "window.restoreWindows": "none",
      "workbench.colorTheme": "Solarized Dark",
      "workbench.editor.swipeToNavigate": true,
      "workbench.iconTheme": "vscode-icons",
      "workbench.preferredDarkColorTheme": "Solarized Dark",
      "workbench.preferredLightColorTheme": "Solarized Light",
      "workbench.startupEditor": "none",
    }
  '';
  keybindingsJson = ''
    [
      {
        "key": "ctrl+cmd+v",
        "command": "toggleVim",
      },
      {
        "key": "ctrl+shift+c",
        "command": "editor.action.clipboardCopyAction",
      },
      {
        "key": "ctrl+shift+v",
        "command": "editor.action.clipboardPasteAction",
      },
    ]
  '';
  mcpJson = ''
    {
    	"servers": {
    		"microsoftdocs/mcp": {
    			"type": "http",
    			"url": "https://learn.microsoft.com/api/mcp",
    			"gallery": "https://api.mcp.github.com",
    			"version": "1.0.0"
    		},
    		"io.github.ChromeDevTools/chrome-devtools-mcp": {
    			"type": "stdio",
    			"command": "npx",
    			"args": [
    				"--registry",
    				"https://registry.npmjs.org",
    				"chrome-devtools-mcp@0.16.0"
    			],
    			"gallery": "https://api.mcp.github.com",
    			"version": "0.16.0"
    		}
    	}
    }
  '';
  extensionsList = ''
    bierner.markdown-mermaid
    bpruitt-goddard.mermaid-markdown-syntax-highlighting
    charliermarsh.ruff
    dbaeumer.vscode-eslint
    esbenp.prettier-vscode
    fill-labs.dependi
    github.copilot-chat
    github.vscode-github-actions
    github.vscode-pull-request-github
    golang.go
    jnoortheen.nix-ide
    ms-azuretools.vscode-containers
    ms-ossdata.vscode-pgsql
    ms-python.debugpy
    ms-python.mypy-type-checker
    ms-python.python
    ms-python.vscode-pylance
    ms-vscode-remote.remote-containers
    ms-vscode-remote.remote-ssh
    ms-vscode-remote.remote-ssh-edit
    ms-vscode.remote-explorer
    openai.chatgpt
    oven.bun-vscode
    redhat.vscode-yaml
    sonarsource.sonarlint-vscode
    sourcegraph.sourcegraph
    svelte.svelte-vscode
    tamasfe.even-better-toml
    usernamehw.errorlens
    vscode-icons-team.vscode-icons
    vscodevim.vim
  '';
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
