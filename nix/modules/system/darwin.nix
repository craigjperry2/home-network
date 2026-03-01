{ config, pkgs, inputs, ... }:

let
  esc = "\x1b";
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
    taps = [];
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  system.defaults.CustomUserPreferences = {
    "com.apple.Safari" = {
      "AlwaysRestoreSessionAtLaunch" = true;
      "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" = true;
    };
    "NSGlobalDomain" = {
      "NSUserKeyEquivalents" = {
        "${esc}Window${esc}Centre" = "~\Uf715";
        "${esc}Window${esc}Fill" = "\Uf715";
        "${esc}Window${esc}Move &amp; Resize${esc}Bottom" = "~^\Uf715";
        "${esc}Window${esc}Move &amp; Resize${esc}Bottom Left" = "^$\Uf715";
        "${esc}Window${esc}Move &amp; Resize${esc}Bottom Right" = "@$\Uf715";
        "${esc}Window${esc}Move &amp; Resize${esc}Left" = "^\Uf715";
        "${esc}Window${esc}Move &amp; Resize${esc}Right" = "@\Uf715";
        "${esc}Window${esc}Move &amp; Resize${esc}Top" = "@~\Uf715";
        "${esc}Window${esc}Move &amp; Resize${esc}Top Left" = "$\Uf715";
        "${esc}Window${esc}Move &amp; Resize${esc}Top Right" = "~$\Uf715";
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
