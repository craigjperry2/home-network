# Home Manager config shared by every macOS host.
{...}: {
  imports = [
    ./core.nix
    ./darwin-rclone.nix
  ];

  home = {
    username = "craig";
    homeDirectory = "/Users/craig";
  };
}
