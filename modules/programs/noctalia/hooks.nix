{ lib, ... }:
{
  flake.modules.homeManager.noctalia.programs.noctalia.settings.hooks = {
    colors_changed = lib.mkBefore [
      "noctalia msg plugin boatette/auto-theme:auto-theme all colors-changed"
    ];

    theme_mode_changed = [
      "noctalia msg plugin boatette/auto-theme:auto-theme all theme-mode-changed"
    ];

    wallpaper_changed = [
      ''noctalia msg plugin boatette/auto-theme:auto-theme all wallpaper-changed "$NOCTALIA_WALLPAPER_PATH"''
    ];
  };
}
