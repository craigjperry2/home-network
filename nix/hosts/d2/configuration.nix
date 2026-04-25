{...}: {
  imports = [
    ../../modules/system/darwin.nix
  ];

  networking = {
    computerName = "d2";
    hostName = "d2";
  };

  homebrew = {
    brews = [];
    casks = [];
    masApps = {};
  };
}
