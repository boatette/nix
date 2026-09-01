{ inputs, ... }:
{
  flake.modules.homeManager.noctalia =
    { config, ... }:
    let
      inherit (config.constants) flakeDir;

      rebuild = inputs.self.lib.rebuild flakeDir;
    in
    {
      programs.noctalia.settings.shell = {
        app_icon_color = "primary";
        app_icon_colorize = false;

        button_borders = false;
        card_borders = false;
        input_borders = false;
        popup_borders = false;
        popup_shadows = false;

        polkit_agent = true;
        password_style = "random";

        launch_apps_as_systemd_services = true;

        screen_time_enabled = true;
        settings_window_translucent = true;

        greeter_sync = {
          auto_sync = true;
          privilege_command = "pkexec";
        };

        launcher = {
          app_grid = true;

          providers = {
            calculator.prefix = "=";
            emoji.prefix = ":";
            wallpaper.prefix = "";
            windows.prefix = "@";
          };
        };

        panel = {
          borders = false;
          transparency_mode = "glass";
          list_item_background = true;

          clipboard_placement = "attached";
          control_center_placement = "attached";
          launcher_placement = "floating";
          session_placement = "attached";
          wallpaper_placement = "attached";

          clipboard_position = "auto";
          session_position = "top_center";
          wallpaper_position = "top_center";

          open_near_click_clipboard = true;
          open_near_click_control_center = true;
        };

        screen_corners.size = 36;

        screenshot = {
          directory = "~/Pictures/Screenshots";
          filename_pattern = "Screenshot from %Y-%m-%d %H-%M-%S";
          confirm_region = true;
          remember_last_region = true;
        };

        session = {
          grid = true;

          actions =
            let
              action = name: shortcut: {
                action = name;
                inherit shortcut;
              };
            in
            [
              (action "lock" "l")
              (action "lock_and_suspend" "u")
              (action "logout" "e")
              (action "reboot" "r")
              (
                (action "command" "b")
                // {
                  command = ''ghostty -e sh -c "${rebuild.os "boot"} && systemctl reboot"'';
                  label = "Rebuild & Reboot";
                }
              )
              ((action "shutdown" "s") // { variant = "destructive"; })
            ];
        };
      };
    };
}
