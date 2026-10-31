{ lib, ... }:
let
  noctalia = cmd: { spawn-sh = "noctalia msg ${cmd}"; };
  locked = bind: bind // { _props.allow-when-locked = true; };
  cooldown = action: {
    _props.cooldown-ms = 150;
    ${action} = { };
  };

  both = mods: a: b: bind: {
    "${mods}+${a}" = bind;
    "${mods}+${b}" = bind;
  };

  workspaces = lib.mergeAttrsList (
    lib.imap1 (n: key: {
      "Mod+${key}".focus-workspace = n;
      "Mod+Shift+${key}".move-window-to-workspace = n;
      "Mod+Ctrl+${key}".move-window-to-workspace = {
        _args = [ n ];
        _props.focus = false;
      };
    }) (lib.stringToCharacters "1234567890")
  );
in
{
  flake.modules.homeManager.niri.wayland.windowManager.niri.settings.binds = lib.mkMerge [
    {
      "Mod+T".spawn = "foot";
      "Mod+W".spawn = "qutebrowser";
      "Mod+E".spawn = "dolphin";
      "Mod+Alt+E".spawn-sh = "foot zsh -ic 'y; exec zsh'";
      "Ctrl+Shift+Escape".spawn-sh = "foot -e btop";

      "Mod+D" = noctalia "panel-toggle launcher";
      "Mod+X" = noctalia "panel-toggle session";
      "Mod+N" = noctalia "panel-toggle control-center";
      "Mod+Alt+V" = noctalia "panel-toggle clipboard";
      "Mod+S" = noctalia "plugin alexander/screen-toolkit:service all toggle";
      "Mod+Comma" = noctalia "settings-toggle";
      "Mod+I" = noctalia "caffeine-toggle";
      "Mod+B" = noctalia "bar-toggle";
      "Alt+Tab" = noctalia "window-switcher";

      "Mod+G".toggle-overview = { };
      "Mod+Slash".show-hotkey-overlay = { };
      "Mod+Q".close-window = { };
      "Mod+Alt+Q".spawn-sh = "kill -9 $(niri msg --json focused-window | jq .pid)";
      "Mod+V".toggle-window-floating = { };
      "Mod+Shift+V".switch-focus-between-floating-and-tiling = { };

      "Mod+A".toggle-column-tabbed-display = { };
      "Mod+Period".expel-window-from-column = { };
      "Mod+BracketLeft".consume-or-expel-window-left = { };
      "Mod+BracketRight".consume-or-expel-window-right = { };

      "Mod+C".center-column = { };
      "Mod+F".maximize-column = { };
      "Mod+Shift+F".fullscreen-window = { };
      "Mod+Ctrl+F".maximize-window-to-edges = { };
      "Mod+R".switch-preset-column-width = { };
      "Mod+Shift+R".switch-preset-column-width-back = { };
      "Mod+Alt+R".switch-preset-window-height = { };
      "Mod+Alt+Shift+R".switch-preset-window-height-back = { };
      "Mod+Minus".set-column-width = "-10%";
      "Mod+Equal".set-column-width = "+10%";
      "Mod+Shift+Minus".set-window-height = "-10%";
      "Mod+Shift+Equal".set-window-height = "+10%";

      "Mod+Home".focus-column-first = { };
      "Mod+End".focus-column-last = { };
      "Mod+Shift+Home".move-column-to-first = { };
      "Mod+Shift+End".move-column-to-last = { };

      "Mod+Tab".focus-workspace-previous = { };

      "Mod+WheelScrollUp" = cooldown "focus-workspace-up";
      "Mod+WheelScrollDown" = cooldown "focus-workspace-down";
      "Mod+Shift+WheelScrollUp" = cooldown "move-column-to-workspace-up";
      "Mod+Shift+WheelScrollDown" = cooldown "move-column-to-workspace-down";
      "Mod+WheelScrollLeft".focus-column-left = { };
      "Mod+WheelScrollRight".focus-column-right = { };
      "Mod+Ctrl+WheelScrollLeft".move-column-left = { };
      "Mod+Ctrl+WheelScrollRight".move-column-right = { };

      "XF86AudioRaiseVolume" = locked (noctalia "volume-up");
      "XF86AudioLowerVolume" = locked (noctalia "volume-down");
      "XF86AudioMute" = locked (noctalia "volume-mute");
      "XF86AudioMicMute" = locked (noctalia "mic-mute");
      "XF86MonBrightnessUp" = locked (noctalia "brightness-up");
      "XF86MonBrightnessDown" = locked (noctalia "brightness-down");
      "Alt+XF86MonBrightnessUp" = locked (noctalia "brightness-up 1");
      "Alt+XF86MonBrightnessDown" = locked (noctalia "brightness-down 1");

      "Print".screenshot-screen = { };
      "Mod+Shift+S".screenshot = { };

      "Ctrl+Alt+BackSpace".quit._props.skip-confirmation = true;
    }

    (both "Mod" "KP_Left" "KP_4" (locked (noctalia "media previous")))
    (both "Mod" "KP_Begin" "KP_5" (locked (noctalia "media toggle")))
    (both "Mod" "KP_Right" "KP_6" (locked (noctalia "media next")))
    (both "Mod" "KP_Up" "KP_8" (locked (noctalia "volume-up")))
    (both "Mod" "KP_Down" "KP_2" (locked (noctalia "volume-down")))

    (both "Mod" "H" "Left" { focus-column-left = { }; })
    (both "Mod" "L" "Right" { focus-column-right = { }; })
    (both "Mod" "K" "Up" { focus-window-up = { }; })
    (both "Mod" "J" "Down" { focus-window-down = { }; })
    (both "Mod+Shift" "H" "Left" { move-column-left = { }; })
    (both "Mod+Shift" "L" "Right" { move-column-right = { }; })
    (both "Mod+Shift" "K" "Up" { move-window-up-or-to-workspace-up = { }; })
    (both "Mod+Shift" "J" "Down" { move-window-down-or-to-workspace-down = { }; })
    (both "Mod+Ctrl" "H" "Left" { focus-monitor-left = { }; })
    (both "Mod+Ctrl" "L" "Right" { focus-monitor-right = { }; })
    (both "Mod+Ctrl" "K" "Up" { focus-monitor-up = { }; })
    (both "Mod+Ctrl" "J" "Down" { focus-monitor-down = { }; })
    (both "Mod+Shift+Ctrl" "H" "Left" { move-column-to-monitor-left = { }; })
    (both "Mod+Shift+Ctrl" "L" "Right" { move-column-to-monitor-right = { }; })
    (both "Mod+Shift+Ctrl" "K" "Up" { move-column-to-monitor-up = { }; })
    (both "Mod+Shift+Ctrl" "J" "Down" { move-column-to-monitor-down = { }; })

    workspaces
  ];
}
