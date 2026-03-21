{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../modules/system/darwin.nix
  ];

  networking = {
    computerName = "r2";
    dns = ["1.1.1.1"];
    hostName = "r2";
    knownNetworkServices = ["Wi-Fi"];
  };

  homebrew = {
    brews = [];
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
