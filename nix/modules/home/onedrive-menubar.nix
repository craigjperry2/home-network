# settings.json for the OneDrive rclone menu-bar app that every Mac installs
# (modules/system/darwin.nix). The app finds rclone on its own.
{
  config,
  lib,
  ...
}: {
  options.homeNetwork.onedriveMenubar.localPath = lib.mkOption {
    type = lib.types.str;
    description = "Local folder the menu-bar app keeps in sync with OneDrive.";
  };

  # force: guided setup saves this file atomically, replacing the link with a
  # regular file; the next switch puts nix's settings back.
  config.home.file."Library/Application Support/OneDriveRcloneMenubar/settings.json" = {
    force = true;
    text = builtins.toJSON {
      rcloneExecutablePath = "";
      configPath = "${config.home.homeDirectory}/.config/rclone/rclone.conf";
      remoteName = "onedrive";
      inherit (config.homeNetwork.onedriveMenubar) localPath;
      intervalSeconds = 1800;
    };
  };
}
