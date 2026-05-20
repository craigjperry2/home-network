# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  pkgs,
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

  # Set your time zone.
  time.timeZone = "Europe/London";

  users.users.craig = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager"];
    initialPassword = "changeme01";
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  environment = {
    shells = with pkgs; [zsh];
    systemPackages = with pkgs; [
      smartmontools
      zfs
    ];
  };

  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
        userServices = true;
      };
      extraServiceFiles = {
        ssh = ''
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
        llama-cpp = ''
          <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
          <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
          <service-group>
            <name replace-wildcards="yes">%h</name>
            <service>
              <type>_llama-cpp._tcp</type>
              <port>11434</port>
            </service>
          </service-group>
        '';
        comfyui = ''
          <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
          <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
          <service-group>
            <name replace-wildcards="yes">%h</name>
            <service>
              <type>_http._tcp</type>
              <port>8188</port>
              <txt-record>path=/</txt-record>
            </service>
          </service-group>
        '';
      };
    };

    openssh.enable = true;
    tailscale.enable = true;
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
        plex = {
          class = "ExternalCommand";
          command = toString (pkgs.writeShellScript "check-plex-remote" ''
            export PATH="${pkgs.systemd}/bin:${pkgs.coreutils}/bin:${pkgs.gnugrep}/bin:$PATH"
            if journalctl -u plex --since "5 minutes ago" | grep -i "state=playing" ; then
              exit 0
            fi
            exit 1
          '');
        };
        llama-cpp = {
          class = "ActiveConnection";
          ports = "11434";
        };
        comfyui = {
          class = "ActiveConnection";
          ports = "8188";
        };
      };
    };
    zfs = {
      autoScrub.enable = true;
    };
    sanoid = {
      enable = true;
      datasets."tank" = {
        recursive = true;
        useTemplate = ["production"];
      };
      templates.production = {
        hourly = 24;
        daily = 7;
        monthly = 12;
        autoprune = true;
        autosnap = true;
      };
    };
    plex = {
      enable = true;
      dataDir = "/srv/vms/plex";
      openFirewall = true;
    };
    immich = {
      enable = true;
      host = "0.0.0.0";
      mediaLocation = "/srv/vms/immich/media";
    };
    postgresql = {
      enable = true;
      dataDir = "/srv/vms/immich/postgres";
    };

    xserver.videoDrivers = ["nvidia"];

    llama-cpp = {
      enable = true;
      model = "/srv/ai/gemma-4-e4b-8bit.gguf";
      package = unstable.llama-cpp.override {cudaSupport = true;};
      port = 11434;
      host = "0.0.0.0";
      extraFlags = [
        "--n-gpu-layers"
        "99"
        "--fit-target"
        "4608"
        "--ctx-size"
        "4096"
        "--cache-type-k"
        "q4_0"
        "--cache-type-v"
        "q4_0"
        "--mmproj"
        "/srv/ai/mmproj-F16.gguf"
        "--image-min-tokens"
        "560"
        "--image-max-tokens"
        "560"
        "--ubatch-size"
        "512"
        "--batch-size"
        "512"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /srv/ai/comfyui 0755 root root -"
    "d /srv/ai/comfyui/input 0755 root root -"
    "d /srv/ai/comfyui/output 0755 root root -"
    "d /srv/ai/comfyui/models 0755 root root -"
    "d /srv/ai/comfyui/custom_nodes 0755 root root -"
    "d /srv/ai/comfyui/user 0755 root root -"
  ];

  systemd.services.llama-cpp.environment = {
    GGML_CUDA_ENABLE_UNIFIED_MEMORY = "1";
  };
  systemd.services.llama-cpp.serviceConfig = {
    SupplementaryGroups = ["video" "render"];
    ReadOnlyPaths = ["/srv/ai"];
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [2283 8188 11434];

  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    open = false; # GTX 1080 Ti does not support open drivers
    nvidiaSettings = true;
  };
  hardware.nvidia-container-toolkit.enable = true;

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    oci-containers = {
      backend = "podman";
      containers.comfyui = {
        image = "ghcr.io/ai-dock/comfyui:latest-cuda";
        ports = ["8188:8188"];
        environment = {
          CLI_ARGS = "--listen 0.0.0.0 --port 8188 --lowvram --reserve-vram 6";
          NVIDIA_VISIBLE_DEVICES = "all";
        };
        volumes = [
          "/srv/ai/comfyui/input:/workspace/ComfyUI/input"
          "/srv/ai/comfyui/output:/workspace/ComfyUI/output"
          "/srv/ai/comfyui/models:/workspace/ComfyUI/models"
          "/srv/ai/comfyui/custom_nodes:/workspace/ComfyUI/custom_nodes"
          "/srv/ai/comfyui/user:/workspace/ComfyUI/user"
        ];
        extraOptions = [
          "--device=nvidia.com/gpu=all"
          "--security-opt=label=disable"
        ];
      };
    };
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

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
