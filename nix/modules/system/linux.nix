{
  pkgs,
  inputs,
  ...
}: {
  nixpkgs.overlays = [
    (
      _: prev: {
        inherit (inputs.nixpkgs-unstable.legacyPackages.${prev.stdenv.hostPlatform.system}) zellij gemini-cli;
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

  users.users.craig.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9pHorrpMijyrP4U8LMZ7oC/jFAr1me9GCNMCGjZG6eGLkLnNb58vQivTblr9JUgBHTbNHJ6TTdcNMjQICCLiQDWrtupa2HOokDEHyserwyCShGwFGEGwdprBs5r4MpRIRyoNqWlfx3IJswV8TmKReQhjShBR91OXfuikIw28A8E7Bh1qLAiDGAfAps1skmQ5aIbxBuDH/uGD0l0wQOhNVXrsQHvZSawTtthjpJ5gpURbjdZ4ZwLmLBHa4sm77/E5QGe9QFIGPoN4JZeUF5Onf1Yu4oebC2W96RRHxhfDYVmneKD7g+6IuILnIB7vVojy/1u0voaQVXVA5h7ozE/AJd+vAe8CBw0bwrmCTJtckqFyEs0+u+jN0cmu51lH+P+jjPc3REZDQKZNqZMsb1y/Zn2LJlv2dspvhi5CPVyXNr2kXXCfw2XISWT+at4vjtRHcPpQSJisq/MP81EO8JzuyXYKYcCMoH7HUkCSom0zmo1WylBPCQtXIHu75Eo8Rj+Bhocs0QHlaWyKuicjqnbWEiOHV2khQACVs9a5xTTSPpOLHNsOoCLzuFUvD9iq4moDAlI8paJaIqR6+HayeTDf6frsGWPnOwDXnG1E6Va54uRb2Rstp3aDp+ifMLSrAfF9Mh6EQky/m69b+gZucs3TtmrRfI6MVK2M4ZLkn4L28nw=="
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBR6v9xL2WGh2Q/kKa4JPjJfNQZmzW0DYrhyzNNndQcu"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINH0Rsc+pShq1HnPIp5OnHT8+GW4s45tA7jJW44NQXg7"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG0B0X1Bg0E3htfqJAxDAra0f2pCGDR5NwiCxycNNse5"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDP5IxeTEUGKHCGIUrzcMuEYhbc6V6PaGfuCRclxDhtxl8A3SqFunuhcSxORTh4yXIA1/guEQa41KMnzQoXT/WtuKbEezHKv1cjCUueF2IG21OEak59ipizYwiG32RRM79dlb40TzTK0g/TT9ocoN9SSB33hUtdi18/tnGEo54+2ev+frQ05t1eL7uKuJv5M4wdLIxiPdDeo2LvZNTZhTWJbivP2JvV/KmbFxs7UcyJLdRoO6l03WV/vG48N+nLPFZM3d06Vg9UKrl/f00aGsJhcSPRjf3xXb1qGmO5qK7aY6obdhc5NmCGruAYbKMuKnw5oP3zldN4p46cNzNcMwzsQ9IyvNxRCfgjSN1kehqQA/DAuzJn92UW0KkiBmgU3bg4vdAMFBAvYkLzrvmZKOOUJs8GwZeLuAtR0lPtgFKQQe0/LmZEJAckHDEudbFqZP0/dreQtauVIJeoJH7gCBmVJIJQ7wNRIw1BXn3NVfPJlz3j6u4oUZwPDnnE5RAzcTmCunCIWFtgG5k6EpUxDcsg5T/B/3ieUBsZgdUrroGAMMI7cHsl7wlCi8I2svTGL6L7G2QSTp1YWWSaP+8QCOWE5jEcBOKww1NZZ0Mm5RGQBTw71QqO37ULCJtwTWYfusF94BQTB+nJKKhEFD6gAuCFevwiATikBzreo3nCETC3rw=="
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];
}
