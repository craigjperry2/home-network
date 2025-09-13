# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, inputs, unstable, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = ["tank"];

  networking.hostName = "s1"; # Define your hostname.
  networking.hostId = "bda8af9f";  # Derived from /etc/machine-id
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;


  

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.alice = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     tree
  #   ];
  # };
  users.users.craig = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "changeme01";
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDWTevJ63ZnTe1ftAB8bUp9oUhPnWsEaMxZnNkw6BpOukFfnwVT9/QcMSXRtY5z1SBfmeIPS/x+Co5BM1rkQlnQ7iETlX68rQUjaCW/f1761hWxvvsG5uWvgarcZWKJorEL5wXSxe41l0IWzzNQaBReNZvN/QCQVDUTQaB5jXGO2rrIa7B4M+rL+oMDQYKVdN66xLKRn6vu0lSkPaTeecTsakQ0XNEnFieYNTyQRh9SAvW4IVZLQnLqZx8Q1MskFE7+uZ0qP5IZdTJWVhSF2j+LRkruOs0dV73JGXNpopunoqHSC+9cg6nS+etRiTnhweRlsvjHSftlsYTxXXnlAuRFSZ+WWIx/KbSbBGnXbJVGitAJVHb1wA4D6f2f2Iw6ngnhJRKZ63tZGqJUJj2v8kDbOp4BAZnGTS6bnqVuGL0Of6AfHbPm5bWn+x6B5NDvgwhbBrYmQn+UQFvP3Y+YZj7qbHohrBVzICNMJSKRDOs2w4DNM/4BZepqlzicX85gedk="
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDRn7uRtz/cItl2cizdD+Rqre53R7CC7yqypaXxnqdtqhY1nyVX+4RrVbqoeV+8IoNU9WEngWOGHFSDBW4Sp3xOEvj678i7tzo1OhkDZi/PLrpnQpzopgiERE9aVwD4XTM9NbhX1ODzyy9Nae+rcsS47XmzrNlWc6yuWNMy4kvqfOp4EefYiVz8IQKiwi3vAIxjfhZtbTLkjNd8K7KgbFg3lROaC3ckjgbJn+RPLH2vy1nYOGulsyFwEEJGpd5Ar2clV7/8OcCOHEwXj+ouNCPrtrmQthpwu/D6+U78x//s3xHlCq3GorrfcoIOCfqMh62uDK/vSvn064ofi4hliQGjloZuTRTLJHxiFX0RBhKp9zHnAR/EkHgI06vcWKqLY4LGC7txvhlD371fiPtUdblR8ppy4DKXNrE/uuGEHiIffrb5KthNMlmq4C+2FBaueD31gIo3rn0p2P92MH6BiVPUC93wsxZulvua0nArHSNwXA5WcPjv43sdjrb+nJSxIhk="
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9pHorrpMijyrP4U8LMZ7oC/jFAr1me9GCNMCGjZG6eGLkLnNb58vQivTblr9JUgBHTbNHJ6TTdcNMjQICCLiQDWrtupa2HOokDEHyserwyCShGwFGEGwdprBs5r4MpRIRyoNqWlfx3IJswV8TmKReQhjShBR91OXfuikIw28A8E7Bh1qLAiDGAfAps1skmQ5aIbxBuDH/uGD0l0wQOhNVXrsQHvZSawTtthjpJ5gpURbjdZ4ZwLmLBHa4sm77/E5QGe9QFIGPoN4JZeUF5Onf1Yu4oebC2W96RRHxhfDYVmneKD7g+6IuILnIB7vVojy/1u0voaQVXVA5h7ozE/AJd+vAe8CBw0bwrmCTJtckqFyEs0+u+jN0cmu51lH+P+jjPc3REZDQKZNqZMsb1y/Zn2LJlv2dspvhi5CPVyXNr2kXXCfw2XISWT+at4vjtRHcPpQSJisq/MP81EO8JzuyXYKYcCMoH7HUkCSom0zmo1WylBPCQtXIHu75Eo8Rj+Bhocs0QHlaWyKuicjqnbWEiOHV2khQACVs9a5xTTSPpOLHNsOoCLzuFUvD9iq4moDAlI8paJaIqR6+HayeTDf6frsGWPnOwDXnG1E6Va54uRb2Rstp3aDp+ifMLSrAfF9Mh6EQky/m69b+gZucs3TtmrRfI6MVK2M4ZLkn4L28nw=="
    ];
  };
      

  # programs.firefox.enable = true;

  programs.zsh.enable = true;

  environment.shells = with pkgs; [ zsh ];


  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
    curl
    ghostty.terminfo
    htop
    neovim
    p7zip
    smartmontools
    sysstat
    unzip
    zellij
    zfs
    zip
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.zfs.autoScrub.enable = true;
  services.zfs.autoSnapshot.enable = true;
  services.zfs.autoSnapshot.frequent = 4;
  services.zfs.autoSnapshot.hourly = 24;
  services.zfs.autoSnapshot.daily = 7;
  services.zfs.autoSnapshot.weekly = 4;
  services.zfs.autoSnapshot.monthly = 12;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };
  
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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
  system.stateVersion = "25.05"; # Did you read the comment?

}

