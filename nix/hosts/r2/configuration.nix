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
    hostName = "r2";
  };

  homebrew = {
    brews = [];
    casks = [
      "lm-studio"
      "steam"
    ];
    masApps = {
      "keymapp" = 6472865291;
      "Xcode" = 497799835;
    };
  };
}
