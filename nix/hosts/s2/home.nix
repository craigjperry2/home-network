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
  };
}
