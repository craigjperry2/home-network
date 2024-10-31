# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.initrd = {
      luks.devices = {
        luksCrypted = {
          device = "/dev/nvme0n1p2";
          preLVM = true;
          allowDiscards = true;
        };
      };
  };

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.copyKernels = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.enableCryptodisk = true ;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.extraEntries = ''
      menuentry "Reboot" {
          reboot
      }
      menuentry "Poweroff" {
          halt
      }
  '';

  # Specify the Zen kernel
  boot.kernelPackages = pkgs.linuxPackages_zen;

  networking.hostName = "r3";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/London";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkb.options in tty.
  };

  services.xserver.enable = true;

  # Set XKB keyboard layout options
  services.xserver.xkb = {
    layout = "gb";                          # Set the keyboard layout to US
    # variant = "colemak_dh";                 # Use the Colemak DH variant
    # options = "caps:escape, compose:ralt, terminate:ctrl_alt_bksp";  # Set additional XKB options
    # options = "misc:extend,lv5:caps_switch_lock,compose:menu";  # Alternative XKB options (commented out)
  };

  services.displayManager.sddm.enable = true;

  programs.hyprland.enable = true;
  environment.sessionVariables.NIX_OZONE_WL = "i";

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Set the default shell for all users to zsh
  # users.defaultShell = pkgs.zsh;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.craig = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
    initialPassword = "changeme01";
  #   openssh.authorizedKeys.keys = [ "ssh-dss AAAAB3Nza... alice@foobar" ];

  #   packages = with pkgs; [
  #     firefox
  #     tree
  #   ];
  };

  # List packages installed in systVem profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    firefox
    kitty 
    neovim
    # emacs
    dolphin
    wofi
    wget
    curl
    git
  ];


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?

}

