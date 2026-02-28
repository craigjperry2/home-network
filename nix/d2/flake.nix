{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";

    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, nix-homebrew, homebrew-core, homebrew-cask, ... }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
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
          taps = [];
          brews = [
            "gemini-cli"
            "imessage-exporter"
            {
              name = "nodejs";
              link = false;
            }
            "opencode"
          ];
          casks = [
            # "aldente"
            "antigravity"
            "audacity"
            "chatgpt"
            # "citrix-workspace"
            "claude"
            "claude-code"
            "codex"
            "codex-app"
            "copilot-cli"
            # "docker-desktop"
            "font-jetbrains-mono-nerd-font"
            "firefox@developer-edition"
            "google-chrome"
            "iina"
            "istat-menus@6"
            "lm-studio"
            "obsidian"
            "orbstack"
            "petrichor"
            # "steam"
            "transmission"
            "visual-studio-code"
          ];
          masApps = {
            "AdGuard for Safari" = 1440147259;
            "Affinity Designer 2" = 1616831348;
            "Affinity Photo 2" = 1616822987;
            "Affinity Publisher 2" = 1606941598;
            "Darkroom" = 953286746;
            # "Eero" = 1023499075;
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
            # "Xcode" = 497799835;
          };
      };

      # not in 25.05 yet
      # networking.applicationFirewall.enable = true;
      # networking.applicationFirewall.enableStealthMode = true;
      networking.computerName = "d2";
      networking.dns = ["1.1.1.1"];
      networking.hostName = "d2";
      networking.knownNetworkServices = [
        "Wi-Fi"
      ];

      security.pam.services.sudo_local.touchIdAuth = true;

      system.defaults.CustomUserPreferences = {
        "com.apple.Safari" = {
          "AlwaysRestoreSessionAtLaunch" = true;
          "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" = true;
          # Haven't figured out the defaults read com.apple.Safari keys for enable web dev tools, above not working on macos 26...
          # "IncludeDevelopMenu" = true;
          # "WebKitDeveloperExtrasEnabledPreferenceKey" = true;
          # "WebKitPreferences.developerExtrasEnabled" = true;
        };
        "NSGlobalDomain" = {
          "NSUserKeyEquivalents" = {
            "Window->Centre" = "~\\Uf715";
            "Window->Fill" = "\\Uf715";
            "Window->Move &amp; Resize->Bottom" = "~^\\Uf715";
            "Window->Move &amp; Resize->Bottom Left" = "^$\\Uf715";
            "Window->Move &amp; Resize->Bottom Right" = "@$\\Uf715";
            "Window->Move &amp; Resize->Left" = "^\\Uf715";
            "Window->Move &amp; Resize->Right" = "@\\Uf715";
            "Window->Move &amp; Resize->Top" = "@~\\Uf715";
            "Window->Move &amp; Resize->Top Left" = "$\\Uf715";
            "Window->Move &amp; Resize->Top Right" = "~$\\Uf715";
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

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      nixpkgs.config.allowUnfree = true;
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#d2
    darwinConfigurations."d2" = nix-darwin.lib.darwinSystem {
      modules = [
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          users.users.craig.home = "/Users/craig";
          home-manager.users.craig = import ./home.nix;
          
          # Pass inputs to home-manager modules
          home-manager.extraSpecialArgs = { inherit inputs; };
        }
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            user = "craig";
            enable = true;
            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
            };
            mutableTaps = false;
            autoMigrate = true;
          };
        }
        ({config, ...}: {
          homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
        })
        configuration
      ];
    };
  };
}
