{
  flake.modules.niri.niri.settings.binds =
    let
      locked = cmd: _: {
        props.allow-when-locked = true;
        content.spawn-sh = cmd;
      };
    in
    {
      "XF86AudioRaiseVolume" = locked "noctalia msg volume-up";
      "XF86AudioLowerVolume" = locked "noctalia msg volume-down";
      "XF86AudioMute" = locked "noctalia msg volume-mute";
      "XF86AudioMicMute" = locked "noctalia msg mic-mute";

      "XF86MonBrightnessUp" = locked "noctalia msg brightness-up";
      "XF86MonBrightnessDown" = locked "noctalia msg brightness-down";

      "Alt+XF86MonBrightnessUp" = locked "noctalia msg brightness-up 1";
      "Alt+XF86MonBrightnessDown" = locked "noctalia msg brightness-down 1";

      "Print".screenshot = _: { };
      "Mod+Shift+S".spawn-sh = "noctalia msg screenshot-region";
    };
}
