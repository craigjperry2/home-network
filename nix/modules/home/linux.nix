# Home Manager config shared by every NixOS host.
_: {
  imports = [
    ./core.nix
  ];

  home = {
    username = "craig";
    homeDirectory = "/home/craig";
  };
}
