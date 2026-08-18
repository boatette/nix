{ pkgs }:

let
  inherit (pkgs) lib;

  act = name: { ${name} = _: { }; };
  keys = names: value: lib.genAttrs names (_: value);

  workspaceBinds = lib.listToAttrs (
    lib.concatMap (n: [
      (lib.nameValuePair "Mod+${toString n}" { focus-workspace = n; })
      (lib.nameValuePair "Mod+Shift+${toString n}" { move-column-to-workspace = n; })
      (lib.nameValuePair "Mod+Ctrl+${toString n}" {
        move-column-to-workspace = _: {
          props = [
            n
            { focus = false; }
          ];
        };
      })
    ]) (lib.range 1 9)
  );

  scrollBind = action: _: {
    props.cooldown-ms = 100;
    content = act action;
  };

  lockedSpawn = cmd: _: {
    props.allow-when-locked = true;
    content.spawn-sh = cmd;
  };
in

{
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
  "Alt+Tab".spawn-sh = "noctalia msg window-switcher";
  "Ctrl+Shift+Escape".spawn-sh = "noctalia msg panel-toggle control-center system";

  "Mod+G" = act "toggle-overview";

  "Mod+Q" = act "close-window";
  "Mod+Shift+Q".spawn-sh =
    ''pid=$(niri msg -j focused-window | jq -r '.pid // empty'); if [ -n "$pid" ]; then kill -9 "$pid"; fi'';

  "Mod+C" = act "center-column";
  "Mod+Ctrl+C" = act "center-visible-columns";
  "Mod+V" = act "toggle-window-floating";
  "Mod+Shift+V" = act "switch-focus-between-floating-and-tiling";

  "Mod+F" = act "maximize-column";
  "Mod+Shift+F" = act "fullscreen-window";
  "Mod+Ctrl+F" = act "expand-column-to-available-width";
  "Mod+R" = act "switch-preset-column-width";
  "Mod+Shift+R" = act "switch-preset-window-height";
  "Mod+Ctrl+R" = act "reset-window-height";
  "Mod+A" = act "toggle-column-tabbed-display";

  "Print" = act "screenshot";
  "Mod+Shift+S".spawn-sh = "noctalia msg screenshot-region";

  "XF86AudioRaiseVolume" = lockedSpawn "noctalia msg volume-up";
  "XF86AudioLowerVolume" = lockedSpawn "noctalia msg volume-down";
  "XF86AudioMute" = lockedSpawn "noctalia msg volume-mute";
  "XF86AudioMicMute" = lockedSpawn "noctalia msg mic-mute";

  "XF86MonBrightnessUp" = lockedSpawn "noctalia msg brightness-up";
  "XF86MonBrightnessDown" = lockedSpawn "noctalia msg brightness-down";
  "Alt+XF86MonBrightnessUp" = lockedSpawn "noctalia msg brightness-up 1";
  "Alt+XF86MonBrightnessDown" = lockedSpawn "noctalia msg brightness-down 1";

  "Mod+BracketLeft" = act "consume-or-expel-window-left";
  "Mod+BracketRight" = act "consume-or-expel-window-right";
  "Mod+Period" = act "expel-window-from-column";

  "Mod+Ctrl+WheelScrollDown".set-window-height = "-5%";
  "Mod+Ctrl+WheelScrollUp".set-window-height = "+5%";

  "Mod+Minus".set-column-width = "-10%";
  "Mod+Equal".set-column-width = "+10%";
  "Mod+Shift+Minus".set-window-height = "-10%";
  "Mod+Shift+Equal".set-window-height = "+10%";

  "Mod+Home" = act "focus-column-first";
  "Mod+End" = act "focus-column-last";
  "Mod+Shift+Home" = act "move-column-to-first";
  "Mod+Shift+End" = act "move-column-to-last";

  "Mod+WheelScrollDown" = scrollBind "focus-workspace-down";
  "Mod+WheelScrollUp" = scrollBind "focus-workspace-up";
  "Mod+Shift+WheelScrollDown" = scrollBind "move-column-to-workspace-down";
  "Mod+Shift+WheelScrollUp" = scrollBind "move-column-to-workspace-up";

  "Mod+WheelScrollRight" = act "focus-column-right";
  "Mod+WheelScrollLeft" = act "focus-column-left";
  "Mod+Ctrl+WheelScrollRight" = act "move-column-right";
  "Mod+Ctrl+WheelScrollLeft" = act "move-column-left";
}
// workspaceBinds
// keys [ "Mod+H" "Mod+Left" ] (act "focus-column-left")
// keys [ "Mod+J" "Mod+Down" ] (act "focus-window-down")
// keys [ "Mod+K" "Mod+Up" ] (act "focus-window-up")
// keys [ "Mod+L" "Mod+Right" ] (act "focus-column-right")

// keys [ "Mod+Shift+H" "Mod+Shift+Left" ] (act "move-column-left")
// keys [ "Mod+Shift+J" "Mod+Shift+Down" ] (act "move-window-down")
// keys [ "Mod+Shift+K" "Mod+Shift+Up" ] (act "move-window-up")
// keys [ "Mod+Shift+L" "Mod+Shift+Right" ] (act "move-column-right")

// keys [ "Mod+Ctrl+H" "Mod+Ctrl+Left" ] (act "focus-monitor-left")
// keys [ "Mod+Ctrl+J" "Mod+Ctrl+Down" ] (act "focus-monitor-down")
// keys [ "Mod+Ctrl+K" "Mod+Ctrl+Up" ] (act "focus-monitor-up")
// keys [ "Mod+Ctrl+L" "Mod+Ctrl+Right" ] (act "focus-monitor-right")

// keys [ "Mod+Shift+Ctrl+H" "Mod+Shift+Ctrl+Left" ] (act "move-column-to-monitor-left")
// keys [ "Mod+Shift+Ctrl+J" "Mod+Shift+Ctrl+Down" ] (act "move-column-to-monitor-down")
// keys [ "Mod+Shift+Ctrl+K" "Mod+Shift+Ctrl+Up" ] (act "move-column-to-monitor-up")
// keys [ "Mod+Shift+Ctrl+L" "Mod+Shift+Ctrl+Right" ] (act "move-column-to-monitor-right")
