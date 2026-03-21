{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../modules/system/darwin.nix
  ];

  networking = {
    computerName = "d2";
    dns = ["1.1.1.1"];
    hostName = "d2";
    knownNetworkServices = ["Wi-Fi"];
  };

  homebrew = {
    brews = [];
    casks = [];
    masApps = {};
  };
}
