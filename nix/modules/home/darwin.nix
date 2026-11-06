# Home Manager config shared by every macOS host.
{...}: {
  imports = [
    ./core.nix
    ./onedrive-menubar.nix
  ];

  home = {
    username = "craig";
    homeDirectory = "/Users/craig";
  };
}
