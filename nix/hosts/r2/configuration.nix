{ config, pkgs, ... }:

{
  imports = [
    ../../modules/system/darwin.nix
  ];

  networking.computerName = "r2";
  networking.dns = ["1.1.1.1"];
  networking.hostName = "r2";
  networking.knownNetworkServices = [ "Wi-Fi" ];

  homebrew = {
    brews = [ ];
    casks = [
      "aldente"
      "lm-studio"
      "steam"
    ];
    masApps = {
      "keymapp" = 6472865291;
      "Xcode" = 497799835;
    };
  };
}
