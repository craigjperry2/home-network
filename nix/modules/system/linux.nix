{
  config,
  pkgs,
  inputs,
  ...
}: {
  nixpkgs.overlays = [
    (
      final: prev: {
        inherit (inputs.nixpkgs-unstable.legacyPackages.${prev.system}) zellij;
      }
    )
  ];
}
