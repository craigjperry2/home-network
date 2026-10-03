{
  pkgs,
  unstable,
  inputs,
  ...
}: {
  nixpkgs.overlays = [
    (
      _: _prev: {
        inherit (unstable) claude-code codex github-copilot-cli nixd alejandra statix deadnix;
      }
    )
  ];

  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    inputs.antigravity-nix.packages.${stdenv.hostPlatform.system}.google-antigravity-cli
    claude-code
    codex
    github-copilot-cli
    curl
    ghostty.terminfo
    htop
    neovim
    p7zip
    sysstat
    unzip
    zellij
    zip
    nixd
    alejandra
    statix
    deadnix
  ];

  users.users.craig.openssh.authorizedKeys.keys = import ../../lib/ssh-keys.nix;

  # Key-only SSH. NixOS allows password logins by default, and wheel has
  # passwordless sudo on these hosts.
  services.openssh.settings = {
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
    PermitRootLogin = "no";
  };

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 28d";
    };
    settings.experimental-features = ["nix-command" "flakes"];
  };
}
