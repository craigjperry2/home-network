# Custom USB NixOS Installer

Install a remote, headless x64 host via a bootable usb drive. These
instructions can be run on a MacOS host with the aarch64 architecture
and it will prepare an x64 bootable USB.

## Pre-requisites

* Docker (i'm using orb stack)

## Steps

On the MacOS host:

```shell
# Put your ssh key(s) in a file
# in my case, i can just grab my pubkeys from github
curl -O https://github.com/craigjperry2.keys
```

Edit the iso.nix file to load the keys:

```nix
{ pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
  ];

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "prohibit-password";

  # TODO: change to suit your SSH keys file
  users.users.root.openssh.authorizedKeys.keyFiles = [
    ./craigjperry2.keys
  ];
}
```

On the MacOS host:

```shell
# Use rosetta to run an x64 image
docker run --platform linux/amd64 --privileged -it -v $(pwd):/work -w /work nixos/nix bash
# --priviledged is required because we're using loopback mount and creating a squashfs
```

Inside the x64 container:

```shell
# Build the iso
nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=iso.nix --option filter-syscalls false --option sandbox false
# Avoid seccomp / docker / rosetta 2 clash by disabling the nix sandbox and BPF filters
# which rosetta struggles with. We're already building in an ephemeral isolated container
# so this sandboxing and syscall filtering is redundant

# Copy from nix store to macos host
cp result/iso/nixos-minimal-25.11.6495.e764fc9a4058-x86_64-linux.iso .
```

On the MacOS host:

```shell
# Identify the usb drive
diskutil list

# Unmount it, NB: disk device
diskutil unmountDisk /dev/diskN

# Flash the iso to a usb drive, NB: rdisk device
sudo dd if=nixos-minimal-23.11...iso of=/dev/rdiskN bs=1m

# Boot the host then login remotely. Ready to run fdisk, mkfs, and nixos-generate-config
ssh root@<ip>
```
