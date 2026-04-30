# s1 Architecture: Media Services & Snapshot Management

This document outlines the architecture for media services (Plex, Immich) and the transition to Sanoid for ZFS snapshot management on the `s1` host.

## Services Architecture

### Native NixOS Modules
Plex and Immich are configured as native NixOS services rather than containers. This allows for:
- Integration with NixOS's rollback mechanism for software updates.
- Native systemd lifecycle management and logging.
- Minimal overhead.

### Storage Layout
Persistent state for these services is explicitly moved from `/var/lib` to the `tank` ZFS pool to ensure data can be snapshotted and managed independently of the OS root.

| Service | Component | Path on ZFS |
| :--- | :--- | :--- |
| **Plex** | Application Data | `/srv/vms/plex` |
| **Immich** | Uploads/Internal | `/srv/vms/immich/media` |
| **Immich** | Database (Postgres) | `/srv/vms/immich/postgres` |
| **Shared** | Media Source | `/srv/media/d2-nas-5tb` |

**Media Access:**
- Immich serves `Pictures/` from the media source.
- Plex serves `Music/`, `Movies/`, and `TV Shows/` from the media source.

## Snapshot Management (Sanoid)

We have transitioned from `services.zfs.autoSnapshot` to `services.sanoid`.

### Retention Policy
Sanoid is configured for the `tank` pool with the `production` template:
- **Hourly:** 24
- **Daily:** 7
- **Monthly:** 12

### Legacy Housekeeping
The old `autoSnapshot` system used the `zfs-auto-snap` prefix. To clean up these legacy snapshots, run:
```bash
zfs list -t snapshot -o name -H | grep 'zfs-auto-snap' | xargs -n1 sudo zfs destroy
```

## Operations

### Upgrades
Before running `uu` (flake update) or `sns` (rebuild), it is recommended to ensure a fresh snapshot exists. Sanoid takes hourly snapshots automatically, but you can trigger a manual one if needed:
```bash
sudo zfs snapshot -r tank/srv/vms@pre-upgrade-$(date +%F-%H%M)
```

### Rollbacks
If a service update causes issues:

1. **Software Rollback:** Reboot and select the previous NixOS generation from the boot menu.
2. **Data Rollback:** If the database or state was corrupted or migrated incompatibly, rollback the ZFS dataset:
   ```bash
   # List snapshots
   zfs list -t snapshot -r tank/srv/vms

   # Rollback a specific dataset (e.g., the database)
   sudo zfs rollback tank/srv/vms/immich/postgres@autosnap_...
   ```
   *Note: Rollback will destroy any data created since the snapshot was taken.*
