# Home Network

This repo is the golden source for automation of my home network configuration.

Repo-local Codex hooks are configured under `.codex/` and mirror the Gemini Nix validation flow.

## Instructions

### MacOS

Assuming a fresh install of MacOS (last fresh install test was MacOS 26 Tahoe) then
there are only 3 steps to a fully configured host:

1. Create the user accounts manually, this is a pragmatic workaround for the
   fact that `dscl` is just awkward to automate (e.g. securetoken not created)
   nix-darwin will adopt the created accounts to perform all remaining config
2. Install nix from determinate systems, NB: choose vanilla nix in the installer
3. Clone this repo then `sudo darwin-rebuild switch --flake .#r2` assuming on r2 host

This will then:

* Install software using nix
* Install software from Mac App Store
* Install Homebrew (managed declaratively via nix)
  * Install various casks from Homebrew
* Configure the user account
  * Desktop settings, e.g. window shortcuts, dock location, sudo via touchid etc.
  * Setup nix home-manager, install & configure software including shell etc.

NB: tokens are not managed in this config, you'll have to manually sign in to services.

#### OneDrive via `rclone`

The native Mac App Store OneDrive app is still kept around during the pilot, but
`rclone` is now configured from nix on the Darwin hosts.

After `darwin-rebuild switch`, bootstrap the `rclone` remote manually:

1. Run `rclone config`
2. Create a remote named `onedrive`
3. Complete the Microsoft login flow in your browser
4. Verify access with `rclone lsd onedrive:`
5. Create the `RCLONE_TEST` sentinel file in the local sync root
6. Create the same sentinel remotely with `rclone copyto RCLONE_TEST onedrive:/RCLONE_TEST`
7. Run `rclone-onedrive-resync` once to seed the local mirror before the background
   launch agent takes over

This rollout uses `rclone bisync`, not `rclone mount`, so `macFUSE` is not
required.

The pilot sync roots are:

* `d2` → `/Volumes/d2 data/craig/onedrive-rclone`
* `r2` → `/Users/craig/onedrive-rclone`

Example bootstrap for `r2`:

```bash
cd /Users/craig/onedrive-rclone
touch RCLONE_TEST
rclone copyto RCLONE_TEST onedrive:/RCLONE_TEST
rclone-onedrive-resync
```

`--check-access` expects `RCLONE_TEST` to exist on both sides before the first
`bisync`, so this is a one-time bootstrap step rather than an indication that
the remote auth is broken.

If you don't want to wait for the next scheduled run after the initial resync,
kick the agent manually:

```bash
launchctl kickstart -k "gui/$(id -u)/org.home-network.rclone-onedrive"
```

Use `rclone authorize onedrive` only for headless setups. Local macOS hosts
should just use `rclone config`.

Because the pilot uses separate local paths, rollback is straightforward: stop
using the `onedrive-rclone` folder and continue with the native OneDrive app
until the `rclone` workflow has been proven.

## History

It's changed over the years, Ansible was a staple tool for the longest time. It's
all nix now. These days it supports far less platforms too.

The last of the old style setup was tagged with
[v0.5.0](https://github.com/craigjperry2/home-network/releases/tag/v0.5.0) in case
i ever need to look back quickly in future.

### Decomissioned Platforms

* **AIX** - never was a fan of this OS and i disliked SMIT or SMITTY or whatever the
  configuration tool was called
* **Solaris (SPARC)** - the place i was working at the time exited Solaris at 10 and
  so my need to keep current faded away over time. Shame really because Solaris
  10 was IMO the best OS of it's time. It led with some ground breaking
  features that you might take for granted today:
  
> #### Aside on Solaris 10
>
> | Kind | Solaris 10 Feature | Modern Inspiration |
> |------|--------------------|--------------------|
> | Modern init system replacement | SMF (Service Management Facility) | systemd on linux, i believe apple launchd was around the same time too |
> | Containers | Zones | BSD Jails came first obviously but these days (writing in 2026) Docker / OCI containers are popular |
> | SDN (Software defined networking) | Crossbow | I don't think i know of an all-in-one equiv, on linux you can compose together something comparable using OpenVSwitch and tc etc. |
> 
> Some things absolutely sucked in Solaris, the patchadd nonsense springs to mind.
> The fact we all relied on a perl script (Patch Check Advanced) to work around some
> braindead decisions by Sun in patch distribution just never ceased to amaze me.

* **Solaris (x86)** - they continued a small number of Solaris 10 on x86 hosts but my
  role changed and at this point i can't recall the last time i packaged up a
  new initial ramdisk or saw the purpley-blue GRUB theme...
* **OpenBSD** - i only ever used OpenBSD for routers, firewalls and spam filters and yet
  it taught me so much, and saved me money - CARP vs VRRP :-) and the securelevel
  concept still appeals today
* **Windows 10** - i was never a windows guy
  * **WSL2** - i left this behind just before native X11 support arrived. No shade
    thrown because I got a lot of value from WSL. Stuff like being able to copy files
    between windows and the linux vm via `wsl.exe` was useful
* **FreeBSD** - for the first time in around 25 years i don't have any boxes running
  FreeBSD but i expect, or at least hope, this is a temporary situation. FreeBSD is
  still one of my favourite OS's although i never ever did a `make world`

### Supported Platforms

It's a small list remaining:

* **Linux distros**: Redhat / Fedora (to keep commercially valuable knowledge up to
  date) & NixOS (i've been red-pilled so all my home boxes are nix now...), although
  i continue to be curious about and occasionally dabble with, the immutable OS's
  (Fedora CoreOS, uBlue etc.)
* **MacOS**: i think a lot of non-unix people don't fully appreciate some of the stuff
  you get out of the box on MacOS (immutable SSV, robust realtime audio etc.). I
  rely on nix-darwin for configuration management

### Prior Repo

Around 2015 I lost access to the github account that hosted the original
[home-network](https://github.com/craigjperry/home-network) repo
