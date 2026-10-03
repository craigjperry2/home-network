# Custom USB NixOS Installer

Install a remote, headless x64 host via a bootable USB drive. The ISO is the
flake's `installer` NixOS configuration (`nix/hosts/installer/`): the minimal
installer plus SSH, accepting the same public keys as the managed Linux hosts
(`nix/lib/ssh-keys.nix`). Its nixpkgs is pinned by `nix/flake.lock`.

## Build the ISO

On any x86_64 Linux machine with Nix (e.g. s1):

```shell
nix build ./nix#installer-iso
ls result/iso/
```

On an Apple Silicon Mac, build inside an x64 container (Docker or OrbStack):

```shell
# Use Rosetta to run an x64 image. --privileged is required because the build
# uses a loopback mount to create a squashfs.
docker run --platform linux/amd64 --privileged -it -v "$(pwd)":/work -w /work nixos/nix bash
```

Inside the x64 container:

```shell
git config --global --add safe.directory /work
# Rosetta struggles with the Nix sandbox's seccomp/BPF filters. The container
# is already ephemeral and isolated, so disable them for this build.
nix --extra-experimental-features 'nix-command flakes' build ./nix#installer-iso \
  --option filter-syscalls false --option sandbox false
cp result/iso/*.iso .
```

## Flash and boot

On the macOS host:

```shell
# Identify the USB drive
diskutil list

# Unmount it, NB: disk device
diskutil unmountDisk /dev/diskN

# Flash the ISO to the USB drive, NB: rdisk device
sudo dd if=nixos-minimal-....iso of=/dev/rdiskN bs=1m

# Boot the host, then log in remotely. Ready to run fdisk, mkfs, and
# nixos-generate-config.
ssh root@<ip>
```
