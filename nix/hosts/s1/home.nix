{ config, pkgs, inputs, ... }:

{
  imports = [
    ../../modules/home/core.nix
  ];

  home.username = "craig";
  home.homeDirectory = "/home/craig";
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    delta
  ];

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  programs.zsh.shellAliases = {
    sec = "nvim ~/Code/github.com/craigjperry2/home-network/nix/hosts/s1/configuration.nix";
    seh = "nvim ~/Code/github.com/craigjperry2/home-network/nix/hosts/s1/home.nix";
    sns = "( cd ~/Code/github.com/craigjperry2/home-network/nix ; sudo nixos-rebuild switch --flake .#s1 )";
    uu = "( cd ~/Code/github.com/craigjperry2/home-network/nix ; nix flake update ); sns";
  };
}
