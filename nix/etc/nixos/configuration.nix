# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz home-manager
      # sudo nix-channel --update
      <home-manager/nixos>
    ];

  boot.initrd = {
      luks.devices = {
        luksCrypted = {
          device = "/dev/nvme0n1p2"; # Replace with your UUID
          preLVM = true; # Unlock before activating LVM
          allowDiscards = true; # Allow TRIM commands for SSDs
        };
      };
  };

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.copyKernels = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.enableCryptodisk = true ;
  boot.loader.efi.efiSysMountPoint = "/boot";
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

  networking.hostName = "r3"; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  time.timeZone = "Europe/London";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
  #  keyMap = "us-colemak-dh";
    useXkbConfig = true; # use xkb.options in tty.
  };

  services.xserver.enable = true;

  services.xserver.xkb = {
    layout = "gb";
    #variant = "colemak_dh";
    #options = "caps:escape, compose:ralt, terminate:ctrl_alt_bksp";
    # options = "misc:extend,lv5:caps_switch_lock,compose:menu";
  };

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "craig";

  programs.hyprland.enable = true;
  environment.sessionVariables.NIX_OZONE_WL = "i";
  environment.sessionVariables.ELECTRON_OZONE_PLATFORM_HINT = "auto";

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Set the default shell for all users to zsh
  # users.defaultShell = pkgs.zsh;

  users.users.craig = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    initialPassword = "changeme01";
  #   openssh.authorizedKeys.keys = [ "ssh-dss AAAAB3Nza... alice@foobar" ];

  #   packages = with pkgs; [
  #     firefox
  #     tree
  #   ];
  };

  home-manager.useGlobalPkgs = true;
  home-manager.users.craig = { pkgs, ... }: {
    home.packages = with pkgs; [
      bat
      eza
      nnn
      gh
      ripgrep
      fzf
      git
      python312
      vscode.fhs
      wget
      curl
      neovim
      emacs
      jq
      bun
      dust
      fd
      go
      sqlite
      duckdb
      xsv
      racket
    ];
    home.sessionVariables = {
      EDITOR = "nvim";
    };
    programs.bash = {
      enable = true;
      shellAliases = {
        cat = "bat";

        gd = "git d";
        gds = "git ds";
      	gl = "git l";
      	gs = "git s";
      	gpl = "git pl";
      	gps = "git ps";
	
      	ls = "eza";

        vi = "nvim";
      	vim = "nvim";
      };
    };
    programs.git = {
      enable = true;
      userName = "Craig Perry";
      userEmail = "craigp84@gmail.com";
      aliases = {
        a = "!git status --short | fzf -m | awk '{print $2}' | xargs git add";
        ac = "!f(){ git add --all . ; git commit --all --message=\"$1\"; };f";
        b = "!git branch -q -a --color=always | sed -e 's/^..//' -e '/->/d' | fzf --ansi --preview-window right:75% --preview 'git log -n $(( $( tput lines ) - 3 )) --color=always --pretty=reference {}' | xargs git switch";
        cm = "commit --message";
        d = "diff --ignore-all-space";
        ds = "diff --staged --ignore-all-space";
        l = "log --topo-order --first-parent --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'";
        la = "log --all --topo-order --first-parent --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'";
        lg = "log --all --oneline --graph --decorate";
        ps = "!git push origin $(git symbolic-ref --short HEAD)";
        pl = "!git pull origin $(git symbolic-ref --short HEAD)";
        s = "status --short --branch";
        w = "whatchanged";
        ctop = "!git log | grep Author | sort | uniq -c | sort -rn";
        ltop = "!git ls-files | xargs -n1 git blame --line-porcelain HEAD | grep '^author ' | sort | uniq -c | sort -nr";
        find = "!f() { git log --pretty=format:\"%h %cd [%cn] %s%d\" --date=relative -S'pretty' -S\"$@\" | fzf -m | awk '{print $1}' | xargs -I {} git diff {}^ {}; }; f";
        # edit conflicted file on merge
        edit-unmerged = "!f() { git ls-files --unmerged | cut -f2 | sort -u ; }; vim `f`";
        # add conflicted file on merge
        add-unmerged = "!f() { git ls-files --unmerged | cut -f2 | sort -u ; }; git add `f`";
      };
    };


    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "24.05";
  };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    firefox
    kitty 
    dolphin
    waybar
    networkmanagerapplet
    fuzzel
    dunst
    pavucontrol
  ];

  fonts.packages = with pkgs; [
    font-awesome
  ];

  virtualisation.docker.enable = true;
  virtualisation.docker.daemon.settings.data-root = "/var/lib/docker";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

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

