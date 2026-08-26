{
  flake.modules.homeManager.umbriel.programs.umbriel.settings.keybinds = {
    "Mod+T" = "spawn:ghostty";
    "Mod+W" = "spawn:zen-beta";
    "Mod+E" = "spawn:dolphin";

    "Mod+Alt+W" = "spawn:helium";
    "Mod+Alt+E" = "spawn:ghostty zsh -ic \"y; exec zsh\"";

    "Mod+D" = "spawn:noctalia msg panel-toggle launcher";
    "Mod+X" = "spawn:noctalia msg panel-toggle session";
    "Mod+Y" = "spawn:noctalia msg panel-toggle wallpaper";
    "Mod+Alt+Y" = "spawn:noctalia msg panel-toggle noctalia/wallhaven:browser";
    "Mod+N" = "spawn:noctalia msg panel-toggle control-center";
    "Mod+Comma" = "spawn:noctalia msg settings-toggle";
    "Mod+I" = "spawn:noctalia msg caffeine-toggle";
    "Alt+Tab" = "spawn:noctalia msg window-switcher";
    "Ctrl+Shift+Escape" = "spawn:noctalia msg panel-toggle control-center system";
  };
}
