{
  lib,
  pkgs,
  ...
}: let
  configDir = "/home/craig/.config/rclone";
  stateDir = "/home/craig/.local/state/onedrive-rclone";
  localPath = "/srv/backups/onedrive";
  remoteName = "onedrive";
  bootstrapMarker = "${stateDir}/initial-resync-complete";
  lockFile = "${stateDir}/sync.lock";

  commonScriptSetup = ''
    set -euo pipefail

    config_file=${lib.escapeShellArg "${configDir}/rclone.conf"}
    local_path=${lib.escapeShellArg localPath}
    remote_name=${lib.escapeShellArg remoteName}
    bootstrap_marker=${lib.escapeShellArg bootstrapMarker}
    lock_file=${lib.escapeShellArg lockFile}
    state_dir=${lib.escapeShellArg stateDir}
    export RCLONE_CONFIG="$config_file"

    mkdir -p "$state_dir"

    ensure_local_path() {
      if ! mountpoint -q /srv/backups; then
        echo "/srv/backups is not a mountpoint; refusing to sync $local_path." >&2
        exit 1
      fi
      mkdir -p "$local_path"
    }

    if [ ! -f "$config_file" ]; then
      echo "rclone config not found at $config_file. Run 'rclone config' and create the '$remote_name' remote first." >&2
      exit 1
    fi

    if ! rclone listremotes | grep -Fxq "$remote_name:"; then
      echo "rclone remote '$remote_name' not found in $config_file." >&2
      exit 1
    fi

    ensure_local_path

    bisync_args=(
      "$remote_name:"
      "$local_path"
      --check-access
      --create-empty-src-dirs
      --exclude="/Personal Vault/**"
      --modify-window
      2s
      --resilient
      --fast-list
      --onedrive-delta
    )
  '';

  syncScript = pkgs.writeShellApplication {
    name = "rclone-onedrive-sync";
    runtimeInputs = [
      pkgs.gnugrep
      pkgs.rclone
      pkgs.util-linux
    ];
    text = ''
      ${commonScriptSetup}

      exec 200>"$lock_file"
      if ! flock -n 200; then
        echo "Another rclone-onedrive sync is already running. Skipping."
        exit 0
      fi

      if [ ! -f "$bootstrap_marker" ]; then
        echo "Initial rclone bootstrap has not completed. Run 'rclone-onedrive-resync' once before relying on the timer." >&2
        exit 1
      fi

      exec rclone bisync "''${bisync_args[@]}"
    '';
  };

  resyncScript = pkgs.writeShellApplication {
    name = "rclone-onedrive-resync";
    runtimeInputs = [
      pkgs.gnugrep
      pkgs.rclone
      pkgs.util-linux
    ];
    text = ''
      ${commonScriptSetup}

      exec 200>"$lock_file"
      if ! flock -n 200; then
        echo "Another rclone-onedrive sync is already running. Refusing to run resync simultaneously." >&2
        exit 1
      fi

      rclone bisync "''${bisync_args[@]}" --resync
      touch "$bootstrap_marker"
    '';
  };
in {
  environment.systemPackages = [
    pkgs.rclone
    syncScript
    resyncScript
  ];

  services.autosuspend.checks = {
    onedrive-sync = {
      class = "Processes";
      processes = "rclone";
    };
  };

  systemd = {
    tmpfiles.rules = [
      "d ${localPath} 0750 craig users -"
      "d ${configDir} 0700 craig users -"
      "d ${stateDir} 0700 craig users -"
    ];

    services.rclone-onedrive-sync = {
      description = "Bi-directional OneDrive sync to /srv/backups/onedrive";
      after = [
        "network-online.target"
        "srv-backups.mount"
      ];
      wants = ["network-online.target"];
      requires = ["srv-backups.mount"];
      serviceConfig = {
        Type = "oneshot";
        User = "craig";
        Group = "users";
        ExecStart = "${syncScript}/bin/rclone-onedrive-sync";
      };
    };

    timers.rclone-onedrive-sync = {
      description = "Hourly timer for OneDrive rclone sync";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "hourly";
        Persistent = true;
        WakeSystem = false;
      };
    };
  };
}
