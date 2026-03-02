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
    brews = [ ];
    casks = [ ];
    masApps = { };
  };
}
