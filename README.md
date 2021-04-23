# home-network

A reboot of an old project from about 7 years ago,
https://github.com/CraigJPerry/home-network - I lost access to that github
account after an unfortunate mistake with 2FA :-)

# Instructions

1. Install Ansible on the bootstrap host (a WSL2 VM in my case) `pip3 install --user ansible`
1. Configure the host details in `hosts`
1. Read the comments in `bootstrap.yml` and decide which strategy you'll run

# Pets or Cattle

Some notes to remind me of the rare occassions i treated a box as a pet.

* FreeBSD 13.0 NAS (nas.home.craigjperry.com)
  * BIOS Setup
    * Enable all 6 HDDs as boot disks - if one drive fails, the bootloader is installed on the other 5
    * Enable low power states and bios fan speed control (workaround weird half-supported acpi/i2c)
    * When power is restored, always power-on
  * Bare metal install (was not PXE installed - NIC/BIOS doesn't support it)
    * Install from USB, FreeBSD standard 1G image (not the minimal one), selections:
      * UTC clock
      * Guided ZFS on root: select all 6 drives, raidz2 scheme, 4G swap per drive, 24G(!) total swap
      * Default 3 partition scheme on all HDDs:
        * p1: 512k, stage 1 boot loader
	* p2: 4G, swap (choose non-mirrored to permit crashdumps)
	* p3: 2.7-3.6Tb depending on disk, ZFS
      * Services
        * sshd
	* ntpdate (on boot)
      * Create "craig" user, additionally a "wheel" member
      * Selective hardening:
        * Clear /tmp on boot
  * Initial boot / post-install setup
    * freebsd-update fetch
    * freebsd-update install
    * pkg update
    * pkg upgrade
    * pkg install -y sudo neovim zsh zsh-completions git python37 py37-ansible-2.9.7
    * visudo - enable wheel
    * python3.7 -m ensurepip
    * Add ssh public key to craig's auth keys
  * Bootstrap to Ansible control from remote node over ssh as craig
  * Other tweaks
    * Install rust toolchain https://rustup.rs/
    * cargo install fd-find ripgrep xsv

