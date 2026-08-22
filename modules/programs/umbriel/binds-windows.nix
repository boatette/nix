{ lib, ... }:
{
  flake.modules.homeManager.umbriel.programs.umbriel.settings.keybinds =
    let
      keys = names: action: lib.genAttrs names (_: action);

      workspaceKeys = lib.listToAttrs (
        lib.concatMap (n: [
          (lib.nameValuePair "Mod+${toString (lib.mod n 10)}" "workspace-switch:${toString n}")
          (lib.nameValuePair "Mod+Shift+${toString (lib.mod n 10)}" "window-move-to-workspace:${toString n}")
        ]) (lib.range 1 10)
      );
    in
    {
      "Mod+G" = "overview-toggle";
      "Mod+Slash" = "cheatsheet-toggle";

      "Mod+Q" = "window-close";

      "Mod+C" = "window-center";
      "Mod+V" = "window-toggle-floating";
      "Mod+P" = "window-toggle-pinned";

      "Mod+F" = "window-toggle-maximize";
      "Mod+Shift+F" = "window-toggle-fullscreen";
      "Mod+Ctrl+F" = "window-toggle-maximize-to-edges";
      "Mod+R" = "window-cycle-width";
      "Mod+Ctrl+R" = "config-reload";
      "Mod+Shift+T" = "spawn:noctalia msg plugin boatette/umbriel-layout:bar all toggle";

      "Mod+BracketLeft" = "window-consume-left";
      "Mod+BracketRight" = "window-expel-right";
      "Mod+Period" = "window-expel-right";

      "Mod+Minus" = "window-modify-width:-0.1";
      "Mod+Equal" = "window-modify-width:0.1";

      "Mod+U" = "scratchpad-toggle";
      "Mod+Shift+U" = "window-move-to-scratchpad";
      "Mod+Ctrl+U" = "window-restore-from-scratchpad";
      "Mod+Tab" = "scratchpad-focus-next";

      "Mod+WheelUp" = "workspace-previous";
      "Mod+WheelDown" = "workspace-next";
      "Mod+WheelLeft" = "window-focus-left";
      "Mod+WheelRight" = "window-focus-right";
      "Mod+Ctrl+WheelLeft" = "column-move-left";
      "Mod+Ctrl+WheelRight" = "column-move-right";
    }
    // keys [ "Mod+H" "Mod+Left" ] "window-focus-left"
    // keys [ "Mod+J" "Mod+Down" ] "window-focus-down"
    // keys [ "Mod+K" "Mod+Up" ] "window-focus-up"
    // keys [ "Mod+L" "Mod+Right" ] "window-focus-right"

    // keys [ "Mod+Shift+H" "Mod+Shift+Left" ] "column-move-left"
    // keys [ "Mod+Shift+J" "Mod+Shift+Down" ] "window-move-down"
    // keys [ "Mod+Shift+K" "Mod+Shift+Up" ] "window-move-up"
    // keys [ "Mod+Shift+L" "Mod+Shift+Right" ] "column-move-right"

    // keys [ "Mod+Ctrl+H" "Mod+Ctrl+Left" ] "output-focus-left"
    // keys [ "Mod+Ctrl+J" "Mod+Ctrl+Down" ] "output-focus-down"
    // keys [ "Mod+Ctrl+K" "Mod+Ctrl+Up" ] "output-focus-up"
    // keys [ "Mod+Ctrl+L" "Mod+Ctrl+Right" ] "output-focus-right"

    // keys [ "Mod+Shift+Ctrl+H" "Mod+Shift+Ctrl+Left" ] "column-move-to-output-left"
    // keys [ "Mod+Shift+Ctrl+J" "Mod+Shift+Ctrl+Down" ] "column-move-to-output-down"
    // keys [ "Mod+Shift+Ctrl+K" "Mod+Shift+Ctrl+Up" ] "column-move-to-output-up"
    // keys [ "Mod+Shift+Ctrl+L" "Mod+Shift+Ctrl+Right" ] "column-move-to-output-right"

    // workspaceKeys;
}
