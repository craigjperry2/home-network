{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # sudo bootctl install
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 15;

  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.kernelParams = [ "quiet" "udev.log_level=0" ];
  boot.consoleLogLevel = 0;

  boot.initrd.verbose = false;
  boot.initrd = {
    luks.devices = {
      luksCrypted = {
        device = "/dev/nvme0n1p2";
        preLVM = true;
        allowDiscards = true;
      };
    };
  };

  boot.plymouth.enable = true;
  boot.plymouth.theme = "bgrt";

  networking.hostName = "r3";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/London";

  i18n.defaultLocale = "en_GB.UTF-8";

  console.useXkbConfig = true;

  services.xserver.enable = true;  # NB: this doesn't choose Xorg vs Wayland
  services.xserver.xkb = {
    layout = "gb";
  };

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "craig";

  programs.hyprland.enable = true;

  environment.sessionVariables.NIX_OZONE_WL = "1";
  environment.sessionVariables.ELECTRON_OZONE_PLATFORM_HINT = "auto";

  environment.shells = with pkgs; [ zsh ];

  users.users.craig = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "changeme01";
    shell = pkgs.zsh;

    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDM9Rft+Op+5VDFBR989z/iY4pr/fVpAbzNmHM3b8badQwDKukcCbYwMWtke4d0/AxeBcK+uoTJHN7ebQewKqm/N7fGpEOrNRBjRLLiOnN6wpUeO06LbEido+lnt3Pf9MHW1W3sorxfpl97CtRuLYtpyBR5i+FowZssyKqAGOntXldEkBB+oK4hQbmVArt76JOIWwNueO9TY3qQGFlKm24qP2JVQN2zFW3pCWJgfeTUITAsEFDg7xhDKWEwN0srf70slc06QvBon4D4afgovkcdFb4vvgw4ucx+6+BnydzLxFa0iEx69aFOnhuMAItFRFxyfRicJYBms2pCUE5Q3lmakr8e6cVz/dxi6a9PDFBkW/n53QhTgzIoKy1z/45ofolzkaeCozMgre/SJNONXHBJwX5yuZjWxkYU0EAOfEDtzBYFVowHMg8UJ3I8QJIiC+cAolmEFhZiAR3nvFEipRqBIZ+EEht53YZdh2cZVyS8r0haq15lDFAGDzFY2w0qO8k="
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDWTevJ63ZnTe1ftAB8bUp9oUhPnWsEaMxZnNkw6BpOukFfnwVT9/QcMSXRtY5z1SBfmeIPS/x+Co5BM1rkQlnQ7iETlX68rQUjaCW/f1761hWxvvsG5uWvgarcZWKJorEL5wXSxe41l0IWzzNQaBReNZvN/QCQVDUTQaB5jXGO2rrIa7B4M+rL+oMDQYKVdN66xLKRn6vu0lSkPaTeecTsakQ0XNEnFieYNTyQRh9SAvW4IVZLQnLqZx8Q1MskFE7+uZ0qP5IZdTJWVhSF2j+LRkruOs0dV73JGXNpopunoqHSC+9cg6nS+etRiTnhweRlsvjHSftlsYTxXXnlAuRFSZ+WWIx/KbSbBGnXbJVGitAJVHb1wA4D6f2f2Iw6ngnhJRKZ63tZGqJUJj2v8kDbOp4BAZnGTS6bnqVuGL0Of6AfHbPm5bWn+x6B5NDvgwhbBrYmQn+UQFvP3Y+YZj7qbHohrBVzICNMJSKRDOs2w4DNM/4BZepqlzicX85gedk="
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCrgbUtLWqld9mHi+mcS/3hhNgrnlEjgOrBL9FfOfZuIjbOtTLQ7WaNycYfPPXUmnKzkPKRWOHg/zdltwjY5Nx/UULxioqhZiQ5XOno6l6x2daUEQP3ZTvnO6XYzrewBMZV6KtwIkUObqfRGIovB+XguW4z1JWvrkh1Q7sUTRxbbVidWBb40XG6IlFSmef6n908KaEbGQcOBDvwtRNWD5QoNv+SEI7G8iP/GT7VL/5q84yOOIcXcICG0PgXWcKpC+BAK5Z/1//+ifrWbavQiZTDyvDKjqDKajsCerAR4ZG2qOYeXTm80PKhJSqOUKwUsdxfDlkQKFI7wg041t1IQzfdx0784/172yG6eo0wyTF27g8QMrNwXbsYuYTSY+1LaoDu1fs0sGbmmWS3Qr9ZWc96736uXf6WyNiQeYLWCQDga4uAyvEuIXweOwBSx/B9erefjcNIYo1e85reaxWCgEKwIn0Bjxy+SmVQIkhhUv2k1EezcnXma5RZPeoEb2Jng8E="
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDRn7uRtz/cItl2cizdD+Rqre53R7CC7yqypaXxnqdtqhY1nyVX+4RrVbqoeV+8IoNU9WEngWOGHFSDBW4Sp3xOEvj678i7tzo1OhkDZi/PLrpnQpzopgiERE9aVwD4XTM9NbhX1ODzyy9Nae+rcsS47XmzrNlWc6yuWNMy4kvqfOp4EefYiVz8IQKiwi3vAIxjfhZtbTLkjNd8K7KgbFg3lROaC3ckjgbJn+RPLH2vy1nYOGulsyFwEEJGpd5Ar2clV7/8OcCOHEwXj+ouNCPrtrmQthpwu/D6+U78x//s3xHlCq3GorrfcoIOCfqMh62uDK/vSvn064ofi4hliQGjloZuTRTLJHxiFX0RBhKp9zHnAR/EkHgI06vcWKqLY4LGC7txvhlD371fiPtUdblR8ppy4DKXNrE/uuGEHiIffrb5KthNMlmq4C+2FBaueD31gIo3rn0p2P92MH6BiVPUC93wsxZulvua0nArHSNwXA5WcPjv43sdjrb+nJSxIhk="
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDP5IxeTEUGKHCGIUrzcMuEYhbc6V6PaGfuCRclxDhtxl8A3SqFunuhcSxORTh4yXIA1/guEQa41KMnzQoXT/WtuKbEezHKv1cjCUueF2IG21OEak59ipizYwiG32RRM79dlb40TzTK0g/TT9ocoN9SSB33hUtdi18/tnGEo54+2ev+frQ05t1eL7uKuJv5M4wdLIxiPdDeo2LvZNTZhTWJbivP2JvV/KmbFxs7UcyJLdRoO6l03WV/vG48N+nLPFZM3d06Vg9UKrl/f00aGsJhcSPRjf3xXb1qGmO5qK7aY6obdhc5NmCGruAYbKMuKnw5oP3zldN4p46cNzNcMwzsQ9IyvNxRCfgjSN1kehqQA/DAuzJn92UW0KkiBmgU3bg4vdAMFBAvYkLzrvmZKOOUJs8GwZeLuAtR0lPtgFKQQe0/LmZEJAckHDEudbFqZP0/dreQtauVIJeoJH7gCBmVJIJQ7wNRIw1BXn3NVfPJlz3j6u4oUZwPDnnE5RAzcTmCunCIWFtgG5k6EpUxDcsg5T/B/3ieUBsZgdUrroGAMMI7cHsl7wlCi8I2svTGL6L7G2QSTp1YWWSaP+8QCOWE5jEcBOKww1NZZ0Mm5RGQBTw71QqO37ULCJtwTWYfusF94BQTB+nJKKhEFD6gAuCFevwiATikBzreo3nCETC3rw=="
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC2Iv4jKFbwqfKoMc+5833F8NkFH5oiyYFqyLE/DCwXDe14rxLscoMFhcE9DD/nicVx1WEipz+3SU8/XV4vf76FE9Hk68bklSx/6AGol5um8pJ4E9HorH+VZ7H289oMQY05Vog2g14qtrNubJ5xCbBrfQhbYjVWEUnOiOrEMQNjDi6hrPpP6og4Ed/T06H8MhuPeYjg44c5L7P7S1w5zmK6Oc9+UH4Xihl6djpW921KcHFfjJoTISjFZATQT7yyIZ5ZigL+wb8lrS0Il+FKtupspzBWqbeTMAo4/8FSWAnMPkmWF7vhJK8ku3tZDZ1brHs6yt83ZRoBqy6mA8xEFRlqPvOKNe2bH8a7Jpnqiqr8Vk3/3veaK5vBUvV0iuFdvhr1Ns8XjUVhqK815LsR0UFni0R1CTZf34lypZyFVmmbwtiFxIBCcmR1jMMDeJh0o4EcWu/RjyvEfafLxcHyyKfEhZOytfiBqCUMOw2Gxx3G243NcnP3czRwhtOoHcr/Gos="
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCvrVYKEtdgry5/mIRhn0TBsq/VdyqBcWumyRkwtQFWmseIWqbC7HQDx62Lsg21N2ZouRT+1ZFBufkf8SAXIbJb+61qj9Anne1DiqmQZesCQiMjE5zrMpGSorP+U0D49+wLi2tLAhI5sbAqY0AL94Y017TlAviwYRwk4Ue9vDJUSC/KOcbsw61DQvIfXsc08DIW6zdUs71cbA6Fh8U5tgU4h6Uat729mMCdmRBRAMCEALnfZxAQY/GaTi9kIXBUdUfw1VV0gD/W0K8ihmNfBERwbeEZ2/vmsPCVnBC8TRt4eLigc2Aq3LN+NmCBL5Awaz5ZRG7CYWCZ5Q1X4zTQQZK9"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCviDNchUaNKYlUjVWUSlwDoI1xrwYl19IrHwTZsKZ8nQUMZJ0qvLI8XGv3jQ1JV6giZaoTU9aBPOS6gektOHWlTBheubW/rrq+OWYQSS3F9LOx12JOI6VHJAtKdBAzKx99RQD7IE0QNQ30alh5yrcO8uy/NnsRsANl3Oa2YPmoAlT3BxjYmkec/Nu20JLxb+/iOVJWKAO5OZ9xdvRPfDvnciX18vFxUK+7/ydE8NTrgtS908S2dXukTPXTHfGIvJjW4hnMurIyNyBEzzJ3wnH1ZWnqJ6pc+NnXR8wwWoc6uCswUafll0c9bEkwuXAPoaDjFBM9cBfedV1Z2dYUzlYsewn6KGMwaLsJ5gPR7y7b2aHICAJxkSrOoqXei4q8/BAbhqgUS52wjzl1QsMcCSY2H5/mj7QvU5oaR0LTt0VyPE26Y/9L7lXm8kRxKMf3Erq7gY7HWMG/PhZK0pDT999HbG3OHvwOoUQRyyh6eVs7zAZJ9D6lnIJFvYeDvoZPLa8="
    ];
  };

  nix.settings.trusted-users = [ "root" "craig" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    brightnessctl
    cachix
    citrix_workspace
    devenv
    dive
    kdePackages.dolphin
    dunst
    firefox
    fuzzel
    killall
    kitty 
    networkmanagerapplet
    pavucontrol
    podman-compose
    podman-tui
    waybar
    zsh
  ];

  programs.zsh.enable = true;

  fonts.packages = with pkgs; [
    font-awesome
    noto-fonts
    noto-fonts-emoji
    nerd-fonts.jetbrains-mono
  ];

  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  services.libinput.enable = true;
  services.openssh.enable = true;

  system.stateVersion = "24.05";
}
