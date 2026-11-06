# Home Manager config shared by every macOS host.
{...}: {
  imports = [./core.nix];

  home = {
    username = "craig";
    homeDirectory = "/Users/craig";
  };
}
