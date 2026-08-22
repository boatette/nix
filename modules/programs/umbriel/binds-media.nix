{
  flake.modules.homeManager.umbriel.programs.umbriel.settings.keybinds = {
    "XF86AudioRaiseVolume" = "spawn:noctalia msg volume-up";
    "XF86AudioLowerVolume" = "spawn:noctalia msg volume-down";
    "XF86AudioMute" = "spawn:noctalia msg volume-mute";
    "XF86AudioMicMute" = "spawn:noctalia msg mic-mute";

    "XF86MonBrightnessUp" = "spawn:noctalia msg brightness-up";
    "XF86MonBrightnessDown" = "spawn:noctalia msg brightness-down";

    "Alt+XF86MonBrightnessUp" = "spawn:noctalia msg brightness-up 1";
    "Alt+XF86MonBrightnessDown" = "spawn:noctalia msg brightness-down 1";

    "Print" = "spawn:noctalia msg screenshot-fullscreen";
    "Mod+Shift+S" = "spawn:noctalia msg screenshot-region";
  };
}
