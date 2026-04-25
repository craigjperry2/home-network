# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  pkgs,
  inputs,
  unstable,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/system/linux.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = ["zfs"];
    zfs.extraPools = ["tank"];
  };

  networking = {
    hostName = "s1"; # Define your hostname.
    hostId = "bda8af9f"; # Derived from /etc/machine-id
    # Pick only one of the below networking options.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    networkmanager.enable = true; # Easiest to use and most distros use this by default.
    interfaces.enp0s31f6.wakeOnLan.enable = true;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
      userServices = true;
    };
    extraServiceFiles.ssh = ''
      <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
      <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
      <service-group>
        <name replace-wildcards="yes">%h</name>
        <service>
          <type>_ssh._tcp</type>
          <port>22</port>
        </service>
      </service-group>
    '';
  };

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
    extraGroups = ["wheel" "networkmanager"];
    initialPassword = "changeme01";
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9pHorrpMijyrP4U8LMZ7oC/jFAr1me9GCNMCGjZG6eGLkLnNb58vQivTblr9JUgBHTbNHJ6TTdcNMjQICCLiQDWrtupa2HOokDEHyserwyCShGwFGEGwdprBs5r4MpRIRyoNqWlfx3IJswV8TmKReQhjShBR91OXfuikIw28A8E7Bh1qLAiDGAfAps1skmQ5aIbxBuDH/uGD0l0wQOhNVXrsQHvZSawTtthjpJ5gpURbjdZ4ZwLmLBHa4sm77/E5QGe9QFIGPoN4JZeUF5Onf1Yu4oebC2W96RRHxhfDYVmneKD7g+6IuILnIB7vVojy/1u0voaQVXVA5h7ozE/AJd+vAe8CBw0bwrmCTJtckqFyEs0+u+jN0cmu51lH+P+jjPc3REZDQKZNqZMsb1y/Zn2LJlv2dspvhi5CPVyXNr2kXXCfw2XISWT+at4vjtRHcPpQSJisq/MP81EO8JzuyXYKYcCMoH7HUkCSom0zmo1WylBPCQtXIHu75Eo8Rj+Bhocs0QHlaWyKuicjqnbWEiOHV2khQACVs9a5xTTSPpOLHNsOoCLzuFUvD9iq4moDAlI8paJaIqR6+HayeTDf6frsGWPnOwDXnG1E6Va54uRb2Rstp3aDp+ifMLSrAfF9Mh6EQky/m69b+gZucs3TtmrRfI6MVK2M4ZLkn4L28nw=="
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBR6v9xL2WGh2Q/kKa4JPjJfNQZmzW0DYrhyzNNndQcu"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINH0Rsc+pShq1HnPIp5OnHT8+GW4s45tA7jJW44NQXg7"
    ];
  };

  # programs.firefox.enable = true;

  programs.zsh.enable = true;

  environment.shells = with pkgs; [zsh];

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    smartmontools
    zfs
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
  services = {
    openssh.enable = true;
    autosuspend = {
      enable = true;
      settings = {
        idle_time = 300;
      };
      checks = {
        ssh = {
          class = "Users";
          # Prevent suspend if any user is logged in via a remote host (SSH)
          host = "[0-9a-fA-F:].*";
        };
      };
    };
    zfs = {
      autoScrub.enable = true;
      autoSnapshot = {
        enable = true;
        frequent = 4;
        hourly = 24;
        daily = 7;
        weekly = 4;
        monthly = 12;
      };
    };
  };

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

  nix.settings.experimental-features = ["nix-command" "flakes"];

  systemd.services.sleepproxy-register = {
    description = "Register with macOS Sleep Proxy";
    before = ["sleep.target"];
    wantedBy = ["sleep.target"];
    serviceConfig = {
      Type = "oneshot";
      # Include specific IPs for proxies that were discovered by Avahi but missed by internal Python discovery.
      # Also add a small delay to ensure the registration packet is sent before suspend.
      ExecStart = "${pkgs.writeShellScript "sleepproxy-run" ''
        ${pkgs.callPackage ../../pkgs/sleepproxyclient.nix {}}/bin/sleepproxyclient \
          --interface enp0s31f6 \
          --debug \
          --preferred-proxies 192.168.7.236 192.168.7.158
        ${pkgs.coreutils}/bin/sleep 2
      ''}";
    };
  };

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
