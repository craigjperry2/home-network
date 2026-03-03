{ config, pkgs, inputs, ... }:

let
  esc = builtins.fromJSON ''"\u001b"'';
  f18 = builtins.fromJSON ''"\uF715"'';
in
{
  environment.systemPackages = [
    pkgs.neovim
    pkgs.mas
  ];

  system.primaryUser = "craig";

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall";
      upgrade = true;
    };
    taps = builtins.attrNames config.nix-homebrew.taps;

    brews = [
      "gemini-cli"
      "imessage-exporter"
      { name = "nodejs"; link = false; }
      "opencode"
    ];
    casks = [
      "antigravity"
      "audacity"
      "chatgpt"
      "claude"
      "claude-code"
      "codex"
      "codex-app"
      "copilot-cli"
      "font-jetbrains-mono-nerd-font"
      "firefox@developer-edition"
      "ghostty"
      "google-chrome"
      "iina"
      "istat-menus@6"
      "obsidian"
      "orbstack"
      "petrichor"
      "transmission"
      "visual-studio-code"
      "wispr-flow"
    ];
    masApps = {
      "AdGuard for Safari" = 1440147259;
      "Affinity Designer 2" = 1616831348;
      "Affinity Photo 2" = 1616822987;
      "Affinity Publisher 2" = 1606941598;
      "Darkroom" = 953286746;
      "Gyroflow" = 6447994244;
      "Home Assistant" = 1099568401;
      "Microsoft Excel" = 462058435;
      "Microsoft OneNote" = 784801555;
      "Microsoft PowerPoint" = 462062816;
      "Microsoft To Do" = 1274495053;
      "Microsoft Word" = 462054704;
      "OneDrive" = 823766827;
      "SponsorBlock" = 1573461917;
      "Tailscale" = 1475387142;
      "Telegram" = 747648890;
      "Userscripts" = 1463298887;
      "Vimlike" = 1584519802;
    };
  };
  vscodeExtensions = [
    "charliermarsh.ruff"
    "dbaeumer.vscode-eslint"
    "esbenp.prettier-vscode"
    "fill-labs.dependi"
    "github.copilot-chat"
    "github.remotehub"
    "jnoortheen.nix-ide"
    "ms-azuretools.vscode-containers"
    "ms-ossdata.vscode-pgsql"
    "ms-python.debugpy"
    "ms-python.python"
    "ms-python.vscode-pylance"
    "ms-vscode-remote.remote-containers"
    "ms-vscode-remote.remote-ssh"
    "ms-vscode-remote.remote-ssh-edit"
    "ms-vscode.remote-explorer"
    "openai.chatgpt"
    "redhat.vscode-yaml"
    "sonarsource.sonarlint-vscode"
    "sourcegraph.sourcegraph"
    "tamasfe.even-better-toml"
    "usernamehw.errorlens"
    "vscode-icons-team.vscode-icons"
    "vscodevim.vim"
  ];

  security.pam.services.sudo_local.touchIdAuth = true;

  system.defaults.CustomUserPreferences = {
    "NSGlobalDomain" = {
      "NSUserKeyEquivalents" = {
        "${esc}Window${esc}Centre" = "~${f18}";
        "${esc}Window${esc}Center" = "~${f18}";
        "${esc}Window${esc}Fill" = "${f18}";
        "${esc}Window${esc}Move & Resize${esc}Bottom" = "~^${f18}";
        "${esc}Window${esc}Move & Resize${esc}Bottom Left" = "^$" + f18;
        "${esc}Window${esc}Move & Resize${esc}Bottom Right" = "@$" + f18;
        "${esc}Window${esc}Move & Resize${esc}Left" = "^${f18}";
        "${esc}Window${esc}Move & Resize${esc}Right" = "@${f18}";
        "${esc}Window${esc}Move & Resize${esc}Top" = "@~${f18}";
        "${esc}Window${esc}Move & Resize${esc}Top Left" = "$" + f18;
        "${esc}Window${esc}Move & Resize${esc}Top Right" = "~$" + f18;
      };
    };
  };

  launchd.user.agents.capslockf18 = {
    serviceConfig = {
      Label = "com.local.KeyRemapping";
      ProgramArguments = [
        "/usr/bin/hidutil"
        "property"
        "--set"
        "{\"UserKeyMapping\":[{\"HIDKeyboardModifierMappingSrc\": 0x700000039, \"HIDKeyboardModifierMappingDst\": 0x70000006D}]}"
      ];
      RunAtLoad = true;
    };
  };

  system.defaults.NSGlobalDomain.AppleInterfaceStyleSwitchesAutomatically = true;
  system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;
  system.defaults.NSGlobalDomain.AppleShowAllFiles = true;
  system.defaults.NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
  system.defaults.NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
  system.defaults.NSGlobalDomain."com.apple.keyboard.fnState" = true;
  system.defaults.NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;
  system.defaults.dock.minimize-to-application = true;
  system.defaults.dock.orientation = "left";
  system.defaults.finder.ShowHardDrivesOnDesktop = true;
  system.defaults.finder.ShowMountedServersOnDesktop = true;
  system.defaults.finder.ShowPathbar = true;
  system.defaults.loginwindow.LoginwindowText = "Owner: craigp84@gmail.com";

  nix.settings.experimental-features = "nix-command flakes";

  system.stateVersion = 6;
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  nix-homebrew = {
    user = "craig";
    enable = true;
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };
    mutableTaps = false;
    autoMigrate = true;
  };
}
