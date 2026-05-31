{pkgs, ...}: {
  imports = [
    ../../modules/home/core.nix
    ../../modules/home/darwin-rclone.nix
  ];

  home = {
    username = "craig";
    homeDirectory = "/Users/craig";
    stateVersion = "25.11";
  };

  home.packages = [
    (pkgs.callPackage ../../pkgs/dirac-cli.nix {})
  ];

  homeNetwork.onedriveRclone = {
    enable = true;
    localPath = "/Users/craig/onedrive-rclone";
    syncIntervalSeconds = 600;
  };
}
