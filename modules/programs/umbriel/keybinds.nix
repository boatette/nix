{
  flake.modules.homeManager.umbriel.programs.umbriel.settings.keybinds =
    let
      locked = action: {
        inherit action;
        allow_when_locked = true;
      };
    in
    {
      "Mod+T" = "spawn:ghostty";
      "Mod+W" = "spawn:zen-beta";
      "Mod+E" = "spawn:dolphin";

      "Mod+Alt+W" = "spawn:helium";
      "Mod+Alt+E" = ''spawn:ghostty -e zsh -ic "y; exec zsh"'';

      "Mod+D" = "spawn:noctalia msg panel-toggle launcher";
      "Mod+X" = "spawn:noctalia msg panel-toggle session";
      "Mod+Y" = "spawn:noctalia msg panel-toggle wallpaper";
      "Mod+Alt+Y" = "spawn:noctalia msg panel-toggle noctalia/wallhaven:browser";
      "Mod+N" = "spawn:noctalia msg panel-toggle control-center";
      "Mod+Comma" = "spawn:noctalia msg settings-toggle";
      "Mod+I" = "spawn:noctalia msg caffeine-toggle";
      "Alt+Tab" = "spawn:noctalia msg window-switcher";
      "Ctrl+Shift+Escape" = "spawn:noctalia msg panel-toggle control-center system";

      "Mod+G" = "overview-toggle";
      "Mod+Slash" = "cheatsheet-toggle";

      "Mod+Q" = "window-close";
      "Mod+Alt+Q" =
        ''spawn:app_id=$(umbriel windows --json | jq -r 'first(.[] | select(.active) | .app_id) // empty'); [ -n "$app_id" ] && { pkill -9 -x "$app_id" || pkill -9 -f "$app_id"; }'';

      "Mod+C" = "column-center";
      # TODO: Mod+Ctrl+C: center-visible-columns
      "Mod+V" = "window-toggle-floating";
      "Mod+Shift+V" = "window-focus-switch-floating";
      "Mod+P" = "window-toggle-pinned";

      "Mod+F" = "window-toggle-maximize";
      "Mod+Shift+F" = "window-toggle-fullscreen";
      "Mod+Ctrl+F" = "window-toggle-maximize-to-edges";
      "Mod+R" = "window-cycle-width";
      # TODO: Mod+Shift+R: switch-preset-window-height
      #       Mod+Ctrl+R: reset-window-height

      # TODO: Mod+A: tabbed-columns
      "Mod+O" = "workspace-set-layout:toggle";

      "Mod+U" = "scratchpad-toggle";
      "Mod+Shift+U" = "window-move-to-scratchpad";
      "Mod+Ctrl+U" = "window-restore-from-scratchpad";
      "Mod+Tab" = "scratchpad-focus-next";

      "Mod+H" = "window-focus-left";
      "Mod+Left" = "window-focus-left";
      "Mod+J" = "window-focus-down";
      "Mod+Down" = "window-focus-down";
      "Mod+K" = "window-focus-up";
      "Mod+Up" = "window-focus-up";
      "Mod+L" = "window-focus-right";
      "Mod+Right" = "window-focus-right";

      "Mod+Home" = "column-focus-first";
      "Mod+End" = "column-focus-last";
      "Mod+Shift+Home" = "column-move-to-first";
      "Mod+Shift+End" = "column-move-to-last";

      "Mod+Shift+H" = "column-move-left";
      "Mod+Shift+Left" = "column-move-left";
      "Mod+Shift+J" = "window-move-down";
      "Mod+Shift+Down" = "window-move-down";
      "Mod+Shift+K" = "window-move-up";
      "Mod+Shift+Up" = "window-move-up";
      "Mod+Shift+L" = "column-move-right";
      "Mod+Shift+Right" = "column-move-right";

      "Mod+Ctrl+H" = "output-focus-left";
      "Mod+Ctrl+Left" = "output-focus-left";
      "Mod+Ctrl+J" = "output-focus-down";
      "Mod+Ctrl+Down" = "output-focus-down";
      "Mod+Ctrl+K" = "output-focus-up";
      "Mod+Ctrl+Up" = "output-focus-up";
      "Mod+Ctrl+L" = "output-focus-right";
      "Mod+Ctrl+Right" = "output-focus-right";

      "Mod+Shift+Ctrl+H" = "column-move-to-output-left";
      "Mod+Shift+Ctrl+Left" = "column-move-to-output-left";
      "Mod+Shift+Ctrl+J" = "column-move-to-output-down";
      "Mod+Shift+Ctrl+Down" = "column-move-to-output-down";
      "Mod+Shift+Ctrl+K" = "column-move-to-output-up";
      "Mod+Shift+Ctrl+Up" = "column-move-to-output-up";
      "Mod+Shift+Ctrl+L" = "column-move-to-output-right";
      "Mod+Shift+Ctrl+Right" = "column-move-to-output-right";

      "Mod+1" = "workspace-switch:1";
      "Mod+2" = "workspace-switch:2";
      "Mod+3" = "workspace-switch:3";
      "Mod+4" = "workspace-switch:4";
      "Mod+5" = "workspace-switch:5";
      "Mod+6" = "workspace-switch:6";
      "Mod+7" = "workspace-switch:7";
      "Mod+8" = "workspace-switch:8";
      "Mod+9" = "workspace-switch:9";
      "Mod+0" = "workspace-switch:10";

      "Mod+Shift+1" = "window-move-to-workspace:1";
      "Mod+Shift+2" = "window-move-to-workspace:2";
      "Mod+Shift+3" = "window-move-to-workspace:3";
      "Mod+Shift+4" = "window-move-to-workspace:4";
      "Mod+Shift+5" = "window-move-to-workspace:5";
      "Mod+Shift+6" = "window-move-to-workspace:6";
      "Mod+Shift+7" = "window-move-to-workspace:7";
      "Mod+Shift+8" = "window-move-to-workspace:8";
      "Mod+Shift+9" = "window-move-to-workspace:9";
      "Mod+Shift+0" = "window-move-to-workspace:10";

      # TODO: Mod+Ctrl+[1... 10]: silent-move-column

      "Mod+BracketLeft" = "window-consume-or-expel-left";
      "Mod+BracketRight" = "window-consume-or-expel-right";
      # TODO: "Mod+Period" = "window-expel";

      "Mod+Minus" = "window-modify-width:-0.1";
      "Mod+Equal" = "window-modify-width:0.1";

      "Mod+Shift+Minus" = "window-modify-height:-0.1";
      "Mod+Shift+Equal" = "window-modify-height:0.1";

      "Mod+MouseMiddle" = "layout-scroll-drag";

      "Mod+WheelUp" = "workspace-previous";
      "Mod+WheelDown" = "workspace-next";
      "Mod+Shift+WheelUp" = "column-move-to-workspace-previous";
      "Mod+Shift+WheelDown" = "column-move-to-workspace-next";
      "Mod+WheelLeft" = "window-focus-left";
      "Mod+WheelRight" = "window-focus-right";
      "Mod+Ctrl+WheelLeft" = "column-move-left";
      "Mod+Ctrl+WheelRight" = "column-move-right";

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
