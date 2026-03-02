{ config, pkgs, ... }:

{
  imports = [
    ../../modules/system/darwin.nix
  ];

  networking.computerName = "d2";
  networking.dns = ["1.1.1.1"];
  networking.hostName = "d2";
  networking.knownNetworkServices = [ "Wi-Fi" ];

  homebrew = {
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
      "lm-studio"
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
      "keymapp" = 6472865291;
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
}
