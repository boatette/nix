{
  lib,
  pkgs,
  ...
}:

{
  hooks = {
    battery_charging = [ ];
    battery_discharging = [ ];
    battery_percentage_changed = [ ];
    battery_plugged = [ ];
    bluetooth_disabled = [ ];
    bluetooth_enabled = [ ];
    colors_changed = [
      "noctalia msg plugin boatette/auto-theme:auto-theme all colors-changed"
      (lib.getExe pkgs.foot-live-theme)
      "${lib.getExe pkgs.nocwall} tint --reason colors"
    ];
    logging_out = [ ];
    power_profile_changed = [ ];
    rebooting = [ ];
    session_locked = [ ];
    session_unlocked = [ ];
    shutting_down = [ ];
    started = [ ];
    theme_mode_changed = [
      "noctalia msg plugin boatette/auto-theme:auto-theme all theme-mode-changed"
    ];
    wallpaper_changed = [
      ''noctalia msg plugin boatette/auto-theme:auto-theme all wallpaper-changed "$NOCTALIA_WALLPAPER_PATH"''
      ''${lib.getExe pkgs.nocwall} tint --reason wallpaper --connector "$NOCTALIA_WALLPAPER_CONNECTOR" --path "$NOCTALIA_WALLPAPER_PATH"''
    ];
    wifi_disabled = [ ];
    wifi_enabled = [ ];
  };
}
