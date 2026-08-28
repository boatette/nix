{
  flake.modules.homeManager.umbriel.programs.umbriel.settings.keybinds =
    let
      locked = action: {
        inherit action;
        allow_when_locked = true;
      };
    in
    {
      "XF86AudioRaiseVolume" = locked "spawn:noctalia msg volume-up";
      "XF86AudioLowerVolume" = locked "spawn:noctalia msg volume-down";
      "XF86AudioMute" = locked "spawn:noctalia msg volume-mute";
      "XF86AudioMicMute" = locked "spawn:noctalia msg mic-mute";

      "XF86MonBrightnessUp" = locked "spawn:noctalia msg brightness-up";
      "XF86MonBrightnessDown" = locked "spawn:noctalia msg brightness-down";

      "Alt+XF86MonBrightnessUp" = locked "spawn:noctalia msg brightness-up 1";
      "Alt+XF86MonBrightnessDown" = locked "spawn:noctalia msg brightness-down 1";

      "Print" = "spawn:noctalia msg screenshot-fullscreen";
      "Mod+Shift+S" = "spawn:noctalia msg screenshot-region";
    };
}
