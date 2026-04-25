{...}: {
  imports = [
    ../../modules/home/core.nix
    ../../modules/home/darwin-rclone.nix
  ];

  home = {
    username = "craig";
    homeDirectory = "/Users/craig";
    stateVersion = "25.11";
  };

  homeNetwork.onedriveRclone = {
    enable = true;
    localPath = "/Volumes/d2 data/craig/onedrive-rclone";
    syncIntervalSeconds = 600;
  };
}
