{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../modules/home/core.nix
    ../../modules/home/darwin-rclone.nix
  ];

  home = {
    username = "craig";
    homeDirectory = "/Users/craig";
    stateVersion = "25.11";
    packages = [];
  };

  homeNetwork.onedriveRclone = {
    enable = true;
    localPath = "/Volumes/d2 data/craig/onedrive-rclone";
    syncIntervalSeconds = 600;
  };

  programs.zsh.shellAliases = {
    sns = "( cd ~/Code/github.com/craigjperry2/home-network/nix ; sudo darwin-rebuild switch --flake .#d2 )";
    uu = "( cd ~/Code/github.com/craigjperry2/home-network/nix ; nix flake update ); sns";
  };
}
