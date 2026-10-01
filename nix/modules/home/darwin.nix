# Home Manager config shared by every macOS host.
{pkgs, ...}: {
  imports = [
    ./core.nix
    ./darwin-rclone.nix
  ];

  home = {
    username = "craig";
    homeDirectory = "/Users/craig";
    packages = [
      (pkgs.callPackage ../../pkgs/agent-browser.nix {})
      (pkgs.callPackage ../../pkgs/dirac-cli.nix {})
    ];
  };
}
