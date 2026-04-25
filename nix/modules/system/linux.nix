{
  config,
  pkgs,
  inputs,
  ...
}: {
  nixpkgs.overlays = [
    (
      final: prev: {
        inherit (inputs.nixpkgs-unstable.legacyPackages.${prev.system}) zellij gemini-cli;
      }
    )
  ];

  environment.systemPackages = with pkgs; [
    curl
    gemini-cli
    ghostty.terminfo
    htop
    neovim
    p7zip
    sysstat
    unzip
    zellij
    zip
  ];
}
