{ lib, ... }:
{
  flake.modules.homeManager.niri =
    { pkgs, ... }:
    let
      spawn = argv: { spawn = argv; };
      noctalia =
        args:
        spawn (
          [
            "noctalia"
            "msg"
          ]
          ++ args
        );

      locked = bind: bind // { _props.allow-when-locked = true; };

      both =
        mods: vim: arrow: action:
        let
          bind = lib.genAttrs [ vim arrow ] (key: "${mods}+${key}");
        in
        {
          ${bind.${vim}}.${action} = { };
          ${bind.${arrow}}.${action} = { };
        };

      forceKill = pkgs.writeShellScript "niri-force-kill" ''
        pid=$(niri msg --json focused-window | ${pkgs.jq}/bin/jq -r '.pid // empty')
        [ -n "$pid" ] && kill -9 "$pid"
      '';

      workspaces = lib.mergeAttrsList (
        map (
          n:
          let
            key = toString (lib.mod n 10);
          in
          {
            "Mod+${key}".focus-workspace = n;
            "Mod+Shift+${key}".move-window-to-workspace = n;
            "Mod+Ctrl+${key}".move-window-to-workspace = {
              _args = [ n ];
              _props.focus = false;
            };
          }
        ) (lib.range 1 10)
      );
    in
    {
      wayland.windowManager.niri.settings.binds = lib.mkMerge [
        {
          "Mod+T" = spawn [ "foot" ];
          "Mod+W" = spawn [ "qutebrowser" ];
          "Mod+E" = spawn [ "dolphin" ];
          "Mod+Alt+E" = spawn [
            "foot"
            "zsh"
            "-ic"
            "y; exec zsh"
          ];
          "Ctrl+Shift+Escape" = spawn [
            "foot"
            "-e"
            "btop"
          ];

          "Mod+D" = noctalia [
            "panel-toggle"
            "launcher"
          ];
          "Mod+X" = noctalia [
            "panel-toggle"
            "session"
          ];
          "Mod+N" = noctalia [
            "panel-toggle"
            "control-center"
          ];
          "Mod+Comma" = noctalia [ "settings-toggle" ];
          "Mod+I" = noctalia [ "caffeine-toggle" ];
          "Mod+B" = noctalia [ "bar-toggle" ];
          "Alt+Tab" = noctalia [ "window-switcher" ];

          "Mod+G".toggle-overview = { };
          "Mod+Q".close-window = { };
          "Mod+Alt+Q" = spawn [ "${forceKill}" ];
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
          "Mod+Minus".set-column-width = "-5%";
          "Mod+Equal".set-column-width = "+5%";
          "Mod+Shift+Minus".set-window-height = "-10%";
          "Mod+Shift+Equal".set-window-height = "+10%";

          "Mod+Home".focus-column-first = { };
          "Mod+End".focus-column-last = { };
          "Mod+Shift+Home".move-column-to-first = { };
          "Mod+Shift+End".move-column-to-last = { };

          "Mod+Tab".focus-workspace-previous = { };

          "Mod+WheelScrollUp" = {
            _props.cooldown-ms = 150;
            focus-workspace-up = { };
          };
          "Mod+WheelScrollDown" = {
            _props.cooldown-ms = 150;
            focus-workspace-down = { };
          };
          "Mod+Shift+WheelScrollUp" = {
            _props.cooldown-ms = 150;
            move-column-to-workspace-up = { };
          };
          "Mod+Shift+WheelScrollDown" = {
            _props.cooldown-ms = 150;
            move-column-to-workspace-down = { };
          };
          "Mod+WheelScrollLeft".focus-column-left = { };
          "Mod+WheelScrollRight".focus-column-right = { };
          "Mod+Ctrl+WheelScrollLeft".move-column-left = { };
          "Mod+Ctrl+WheelScrollRight".move-column-right = { };

          "XF86AudioRaiseVolume" = locked (noctalia [ "volume-up" ]);
          "XF86AudioLowerVolume" = locked (noctalia [ "volume-down" ]);
          "XF86AudioMute" = locked (noctalia [ "volume-mute" ]);
          "XF86AudioMicMute" = locked (noctalia [ "mic-mute" ]);
          "XF86MonBrightnessUp" = locked (noctalia [ "brightness-up" ]);
          "XF86MonBrightnessDown" = locked (noctalia [ "brightness-down" ]);
          "Alt+XF86MonBrightnessUp" = locked (noctalia [
            "brightness-up"
            "1"
          ]);
          "Alt+XF86MonBrightnessDown" = locked (noctalia [
            "brightness-down"
            "1"
          ]);

          "Print".screenshot-screen = { };
          "Mod+Shift+S".screenshot = { };

          "Ctrl+Alt+BackSpace".quit._props.skip-confirmation = true;
        }

        (lib.mergeAttrsList (
          map (k: lib.genAttrs [ "Mod+KP_${k.off}" "Mod+KP_${k.on}" ] (_: locked (noctalia k.action))) [
            {
              off = "Left";
              on = "4";
              action = [
                "media"
                "previous"
              ];
            }
            {
              off = "Begin";
              on = "5";
              action = [
                "media"
                "toggle"
              ];
            }
            {
              off = "Right";
              on = "6";
              action = [
                "media"
                "next"
              ];
            }
            {
              off = "Up";
              on = "8";
              action = [ "volume-up" ];
            }
            {
              off = "Down";
              on = "2";
              action = [ "volume-down" ];
            }
          ]
        ))

        (both "Mod" "H" "Left" "focus-column-left")
        (both "Mod" "L" "Right" "focus-column-right")
        (both "Mod" "K" "Up" "focus-window-up")
        (both "Mod" "J" "Down" "focus-window-down")
        (both "Mod+Shift" "H" "Left" "move-column-left")
        (both "Mod+Shift" "L" "Right" "move-column-right")
        (both "Mod+Shift" "K" "Up" "move-window-up")
        (both "Mod+Shift" "J" "Down" "move-window-down")
        (both "Mod+Ctrl" "H" "Left" "focus-monitor-left")
        (both "Mod+Ctrl" "L" "Right" "focus-monitor-right")
        (both "Mod+Ctrl" "K" "Up" "focus-monitor-up")
        (both "Mod+Ctrl" "J" "Down" "focus-monitor-down")
        (both "Mod+Shift+Ctrl" "H" "Left" "move-column-to-monitor-left")
        (both "Mod+Shift+Ctrl" "L" "Right" "move-column-to-monitor-right")
        (both "Mod+Shift+Ctrl" "K" "Up" "move-column-to-monitor-up")
        (both "Mod+Shift+Ctrl" "J" "Down" "move-column-to-monitor-down")

        workspaces
      ];
    };
}
