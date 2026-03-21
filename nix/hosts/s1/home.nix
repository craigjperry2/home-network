{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../../modules/home/core.nix
  ];

  home = {
    username = "craig";
    homeDirectory = "/home/craig";
    stateVersion = "25.11";
    packages = [];
  };

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  programs.zsh.shellAliases = {
    sns = "( cd ~/Code/github.com/craigjperry2/home-network/nix ; sudo nixos-rebuild switch --flake .#s1 )";
    uu = "( cd ~/Code/github.com/craigjperry2/home-network/nix ; nix flake update ); sns";
  };
}
