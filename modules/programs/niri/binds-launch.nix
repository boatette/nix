{
  flake.modules.niri.niri.settings.binds = {
    "Mod+T".spawn-sh = "footclient-themed";
    "Mod+W".spawn-sh = "zen-beta";
    "Mod+E".spawn-sh = "dolphin";

    "Mod+Alt+T".spawn-sh = "ghostty";
    "Mod+Alt+W".spawn-sh = "helium";
    "Mod+Alt+E".spawn-sh = "foot fish -C y";

    "Mod+D".spawn-sh = "noctalia msg panel-toggle launcher";
    "Mod+X".spawn-sh = "noctalia msg panel-toggle session";
    "Mod+Y".spawn-sh = "noctalia msg panel-toggle wallpaper";
    "Mod+Alt+Y".spawn-sh = "noctalia msg panel-toggle noctalia/wallhaven:browser";
    "Mod+N".spawn-sh = "noctalia msg panel-toggle control-center";
    "Mod+Comma".spawn-sh = "noctalia msg settings-toggle";
    "Mod+I".spawn-sh = "noctalia msg caffeine-toggle";
    "Alt+Tab".spawn-sh = "noctalia msg window-switcher";
    "Ctrl+Shift+Escape".spawn-sh = "noctalia msg panel-toggle control-center system";
  };
}
