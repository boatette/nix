{
  flake.modules.homeManager.boatette =
    { lib, pkgs, ... }:
    let
      jq = lib.getExe pkgs.jq;

      locked = action: {
        inherit action;
        allow_when_locked = true;
      };

      focusTabOr =
        name: tab: row:
        "spawn ${pkgs.writeShellScript name ''
          if umbriel windows --json | ${jq} -e 'any(.[]; .active and .tabbed)' >/dev/null; then
            exec umbriel msg ${tab}
          else
            exec umbriel msg ${row}
          fi
        ''}";

      arrows = {
        H = "Left";
        J = "Down";
        K = "Up";
        L = "Right";
      };

      # each hjkl bind also on its arrow key
      withArrows =
        mods: actions:
        lib.concatMapAttrs (key: action: {
          "${mods}${key}" = action;
          "${mods}${arrows.${key}}" = action;
        }) actions;

      workspaces = lib.concatMapAttrs (
        key: n:
        let
          workspace = toString n;
        in
        {
          "Mod+${key}" = "workspace-switch ${workspace}";
          "Mod+Shift+${key}" = "window-move-to-workspace ${workspace}";
          "Mod+Ctrl+${key}" = "window-move-to-workspace-silent ${workspace}";
        }
      ) (lib.genAttrs' (lib.range 1 10) (n: lib.nameValuePair (toString (lib.mod n 10)) n));

      # numlock off and on
      keypad = lib.concatMapAttrs (
        off:
        { on, action }:
        {
          "Mod+${off}" = locked action;
          "Mod+${on}" = locked action;
        }
      );
    in
    {
      programs.umbriel.settings.keybinds =
        withArrows "Mod+Shift+" {
          H = "column-move-left";
          J = "window-move-down";
          K = "window-move-up";
          L = "column-move-right";
        }
        // withArrows "Mod+Ctrl+" {
          H = "output-focus-left";
          J = "output-focus-down";
          K = "output-focus-up";
          L = "output-focus-right";
        }
        // withArrows "Mod+Shift+Ctrl+" {
          H = "column-move-to-output-left";
          J = "column-move-to-output-down";
          K = "column-move-to-output-up";
          L = "column-move-to-output-right";
        }
        // workspaces
        // keypad {
          KP_Left = {
            on = "KP_4";
            action = "spawn noctalia msg media previous";
          };
          KP_Begin = {
            on = "KP_5";
            action = "spawn noctalia msg media toggle";
          };
          KP_Right = {
            on = "KP_6";
            action = "spawn noctalia msg media next";
          };
          KP_Up = {
            on = "KP_8";
            action = "spawn noctalia msg volume-up";
          };
          KP_Down = {
            on = "KP_2";
            action = "spawn noctalia msg volume-down";
          };
        }
        // {
          "Mod+T" = "spawn foot";
          "Mod+W" = "spawn qutebrowser";
          "Mod+E" = "spawn luciole";
          "Mod+Alt+E" = ''spawn foot zsh -ic "y; exec zsh"'';
          "Ctrl+Shift+Escape" = "spawn foot -e btop";

          "Mod+D" = "spawn noctalia msg panel-toggle launcher";
          "Mod+X" = "spawn noctalia msg panel-toggle session";
          "Mod+N" = "spawn noctalia msg panel-toggle control-center";
          "Mod+Alt+V" = "spawn noctalia msg panel-toggle clipboard";
          "Mod+Comma" = "spawn noctalia msg settings-toggle";
          "Mod+I" = "spawn noctalia msg caffeine-toggle";
          "Alt+Tab" = "spawn noctalia msg window-switcher";

          "Mod+G" = "overview-toggle";
          "Mod+Slash" = "cheatsheet-toggle";
          "Mod+Shift+Comma" = "config-reload";

          "Mod+Q" = "window-close";
          "Mod+Alt+Q" =
            "spawn kill -9 $(umbriel windows --json | ${jq} 'first(.[] | select(.active) | .pid)')";

          "Mod+C" = "column-center";
          "Mod+V" = "window-toggle-floating";
          "Mod+Shift+V" = "window-focus-switch-floating";
          "Mod+P" = "window-toggle-pinned";

          "Mod+F" = "window-toggle-maximize";
          "Mod+Shift+F" = "window-toggle-fullscreen";
          "Mod+Ctrl+F" = "window-toggle-maximize-to-edges";
          "Mod+R" = "window-cycle-primary-extent";
          "Mod+Shift+R" = "window-cycle-primary-extent-back";
          "Mod+Alt+R" = "window-cycle-secondary-extent";
          "Mod+Alt+Shift+R" = "window-cycle-secondary-extent-back";

          "Mod+A" = "column-toggle-tabbed";
          "Mod+O" = "workspace-set-layout toggle";
          "Mod+Shift+O" = "workspace-set-layout toggle scrolling stacking master dwindle";

          "Mod+U" = "scratchpad-toggle main";
          "Mod+Shift+U" = "window-move-to-scratchpad main";
          "Mod+Ctrl+U" = "window-restore-from-scratchpad main";
          "Mod+Tab" = "scratchpad-focus-next main";
          "Mod+M" = "scratchpad-toggle rmpc";

          "Mod+H" = "window-focus-left";
          "Mod+Left" = "window-focus-left";
          "Mod+J" = focusTabOr "focus-down" "column-focus-tab-next" "window-focus-down";
          "Mod+Down" = "window-focus-down";
          "Mod+K" = focusTabOr "focus-up" "column-focus-tab-previous" "window-focus-up";
          "Mod+Up" = "window-focus-up";
          "Mod+L" = "window-focus-right";
          "Mod+Right" = "window-focus-right";

          "Mod+Home" = "column-focus-first";
          "Mod+End" = "column-focus-last";
          "Mod+Shift+Home" = "column-move-to-first";
          "Mod+Shift+End" = "column-move-to-last";

          "Mod+BracketLeft" = "window-consume-or-expel-left";
          "Mod+BracketRight" = "window-consume-or-expel-right";
          # TODO: bind once umbriel has it
          # "Mod+Period" = "window-expel";

          "Mod+Minus" = "window-modify-primary-extent -0.1";
          "Mod+Equal" = "window-modify-primary-extent 0.1";
          "Mod+Shift+Minus" = "window-modify-secondary-extent -0.1";
          "Mod+Shift+Equal" = "window-modify-secondary-extent 0.1";

          "Mod+MouseMiddle" = "layout-scroll-drag";
          "Mod+WheelUp" = "workspace-previous";
          "Mod+WheelDown" = "workspace-next";
          "Mod+Shift+WheelUp" = "column-move-to-workspace-previous";
          "Mod+Shift+WheelDown" = "column-move-to-workspace-next";
          "Mod+WheelLeft" = "window-focus-left";
          "Mod+WheelRight" = "window-focus-right";
          "Mod+Ctrl+WheelLeft" = "column-move-left";
          "Mod+Ctrl+WheelRight" = "column-move-right";

          "XF86AudioRaiseVolume" = locked "spawn noctalia msg volume-up";
          "XF86AudioLowerVolume" = locked "spawn noctalia msg volume-down";
          "XF86AudioMute" = locked "spawn noctalia msg volume-mute";
          "XF86AudioMicMute" = locked "spawn noctalia msg mic-mute";
          "XF86MonBrightnessUp" = locked "spawn noctalia msg brightness-up";
          "XF86MonBrightnessDown" = locked "spawn noctalia msg brightness-down";
          "Alt+XF86MonBrightnessUp" = locked "spawn noctalia msg brightness-up 1";
          "Alt+XF86MonBrightnessDown" = locked "spawn noctalia msg brightness-down 1";

          "Print" = "spawn noctalia msg screenshot-fullscreen";
          "Mod+Shift+S" = "spawn noctalia msg screenshot-region";
        };
    };
}
