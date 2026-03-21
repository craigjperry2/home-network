{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.homeNetwork.onedriveRclone;
  configDir = "${config.home.homeDirectory}/.config/rclone";
  stateDir = "${config.home.homeDirectory}/.local/state/onedrive-rclone";
  logDir = "${config.home.homeDirectory}/Library/Logs/onedrive-rclone";
  bootstrapMarker = "${stateDir}/initial-resync-complete";

  commonScriptSetup = ''
    set -euo pipefail

    config_file=${lib.escapeShellArg "${configDir}/rclone.conf"}
    local_path=${lib.escapeShellArg cfg.localPath}
    remote_name=${lib.escapeShellArg cfg.remoteName}
    bootstrap_marker=${lib.escapeShellArg bootstrapMarker}
    export RCLONE_CONFIG="$config_file"

    ensure_local_path() {
      case "$local_path" in
        /Volumes/*)
          local volume_remainder="''${local_path#/Volumes/}"
          local volume_name="''${volume_remainder%%/*}"
          local volume_root="/Volumes/$volume_name"

          if [ ! -d "$volume_root" ]; then
            echo "Volume root $volume_root is unavailable; refusing to sync $local_path." >&2
            exit 1
          fi
          ;;
      esac

      mkdir -p "$local_path"
    }

    mkdir -p ${lib.escapeShellArg stateDir}

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
    )
  '';

  syncScript = pkgs.writeShellApplication {
    name = "rclone-onedrive-sync";
    runtimeInputs = [
      pkgs.gnugrep
      pkgs.rclone
    ];
    text = ''
      ${commonScriptSetup}

      if [ ! -f "$bootstrap_marker" ]; then
        echo "Initial rclone bootstrap has not completed. Run 'rclone-onedrive-resync' once before relying on the launch agent." >&2
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
    ];
    text = ''
      ${commonScriptSetup}

      rclone bisync "''${bisync_args[@]}" --resync
      touch "$bootstrap_marker"
    '';
  };
in {
  options.homeNetwork.onedriveRclone = {
    enable = lib.mkEnableOption "OneDrive sync via rclone on macOS";

    localPath = lib.mkOption {
      type = lib.types.str;
      description = "Local directory used for the rclone-managed OneDrive mirror.";
    };

    remoteName = lib.mkOption {
      type = lib.types.str;
      default = "onedrive";
      description = "Name of the rclone remote that points at OneDrive.";
    };

    syncIntervalSeconds = lib.mkOption {
      type = lib.types.ints.positive;
      default = 300;
      description = "How often the launchd agent runs rclone bisync.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.rclone
      resyncScript
      syncScript
    ];

    home.activation.ensureOneDriveRcloneDirectories = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p ${lib.escapeShellArg configDir}
      mkdir -p ${lib.escapeShellArg stateDir}
      mkdir -p ${lib.escapeShellArg logDir}

      local_path=${lib.escapeShellArg cfg.localPath}

      case "$local_path" in
        /Volumes/*)
          volume_remainder="''${local_path#/Volumes/}"
          volume_name="''${volume_remainder%%/*}"
          volume_root="/Volumes/$volume_name"

          if [ -d "$volume_root" ]; then
            mkdir -p "$local_path"
          else
            echo "Skipping creation of $local_path because $volume_root is not mounted." >&2
          fi
          ;;
        *)
          mkdir -p "$local_path"
          ;;
      esac
    '';

    launchd.agents."org.home-network.rclone-onedrive" = {
      enable = true;
      config = {
        Label = "org.home-network.rclone-onedrive";
        ProcessType = "Background";
        ProgramArguments = [
          "${syncScript}/bin/rclone-onedrive-sync"
        ];
        RunAtLoad = true;
        StandardErrorPath = "${logDir}/stderr.log";
        StandardOutPath = "${logDir}/stdout.log";
        StartInterval = cfg.syncIntervalSeconds;
        WorkingDirectory = config.home.homeDirectory;
      };
    };
  };
}
