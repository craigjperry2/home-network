{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../modules/home/core.nix
  ];

  home = {
    username = "craig";
    homeDirectory = "/Users/craig";
    stateVersion = "25.11";
    packages = [];
  };

  programs.zsh.shellAliases = {
    sns = "( cd ~/Code/github.com/craigjperry2/home-network/nix ; sudo darwin-rebuild switch --flake .#r2 )";
    uu = "( cd ~/Code/github.com/craigjperry2/home-network/nix ; nix flake update ); sns";
  };
}
