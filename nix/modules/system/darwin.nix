{
  config,
  pkgs,
  inputs,
  ...
}: let
  esc = builtins.fromJSON ''"\u001b"'';
  f18 = builtins.fromJSON ''"\uF715"'';
  upArrow = builtins.fromJSON ''"\uF700"'';
  downArrow = builtins.fromJSON ''"\uF701"'';
  leftArrow = builtins.fromJSON ''"\uF702"'';
  rightArrow = builtins.fromJSON ''"\uF703"'';
in {
  environment.systemPackages = [
    pkgs.neovim
    pkgs.mas
  ];

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "uninstall";
      upgrade = true;
    };
    taps = builtins.attrNames config.nix-homebrew.taps;

    brews = [
      "arthur-ficial/homebrew-tap/apfel"
      "gemini-cli"
      "imessage-exporter"
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
      "little-snitch"
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
  # Not available in 25.11: https://github.com/nix-darwin/nix-darwin/pull/1222
  # vscode = [
  #   "charliermarsh.ruff"
  #   "dbaeumer.vscode-eslint"
  #   "esbenp.prettier-vscode"
  #   "fill-labs.dependi"
  #   "github.copilot-chat"
  #   "github.remotehub"
  #   "jnoortheen.nix-ide"
  #   "ms-azuretools.vscode-containers"
  #   "ms-ossdata.vscode-pgsql"
  #   "ms-python.debugpy"
  #   "ms-python.python"
  #   "ms-python.vscode-pylance"
  #   "ms-vscode-remote.remote-containers"
  #   "ms-vscode-remote.remote-ssh"
  #   "ms-vscode-remote.remote-ssh-edit"
  #   "ms-vscode.remote-explorer"
  #   "openai.chatgpt"
  #   "redhat.vscode-yaml"
  #   "sonarsource.sonarlint-vscode"
  #   "sourcegraph.sourcegraph"
  #   "tamasfe.even-better-toml"
  #   "usernamehw.errorlens"
  #   "vscode-icons-team.vscode-icons"
  #   "vscodevim.vim"
  # ];

  security.pam.services.sudo_local.touchIdAuth = true;

  system = {
    primaryUser = "craig";
    defaults = {
      CustomUserPreferences = {
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
            "${esc}Window${esc}Move to DELL U2722DE" = "^~@" + upArrow;
            "${esc}Window${esc}Move to Built-in Retina Display" = "^~@" + downArrow;
            "${esc}Window${esc}Move Window Back to Mac" = "^~@" + leftArrow;
            "${esc}Window${esc}Move to iPad M1" = "^~@" + rightArrow;
          };
        };
      };
      NSGlobalDomain = {
        AppleInterfaceStyleSwitchesAutomatically = true;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        "com.apple.keyboard.fnState" = true;
        "com.apple.mouse.tapBehavior" = 1;
      };
      dock = {
        minimize-to-application = true;
        orientation = "left";
      };
      finder = {
        ShowHardDrivesOnDesktop = true;
        ShowMountedServersOnDesktop = true;
        ShowPathbar = true;
      };
      loginwindow.LoginwindowText = "Owner: craigp84@gmail.com";
    };
    stateVersion = 6;
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

  nix.settings.experimental-features = "nix-command flakes";

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  nix-homebrew = {
    user = "craig";
    enable = true;
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
      "arthur-ficial/homebrew-tap" = inputs.arthur-ficial-tap;
    };
    mutableTaps = false;
    autoMigrate = true;
  };
}
