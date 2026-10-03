# Minimal x86_64 NixOS installer ISO with SSH enabled, for installing headless
# hosts. Build with `nix build ./nix#installer-iso`; see docs/installer.md.
{modulesPath, ...}: {
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "prohibit-password";
  };

  users.users.root.openssh.authorizedKeys.keys = import ../../lib/ssh-keys.nix;
}
