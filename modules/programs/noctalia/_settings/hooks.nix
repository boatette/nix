{
  lib,
  pkgs,
  monitors,
  homeDirectory,
  templates,
  primaryMonitor,
  loginBoxes,
  ...
}:

{
  hooks = {
    colors_changed = [
      "noctalia msg plugin boatette/auto-theme:auto-theme all colors-changed"
      (lib.getExe pkgs.foot-live-theme)
    ];
    theme_mode_changed = [
      "noctalia msg plugin boatette/auto-theme:auto-theme all theme-mode-changed"
    ];
    wallpaper_changed = [
      ''noctalia msg plugin boatette/auto-theme:auto-theme all wallpaper-changed "$NOCTALIA_WALLPAPER_PATH"''
    ];
  };
}
