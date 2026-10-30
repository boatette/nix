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
        animation.enabled = true;

        app_icon_color = "primary";
        app_icon_colorize = false;

        button_borders = true;
        card_borders = true;
        input_borders = true;
        popup_borders = true;

        popup_shadows = false;

        settings_window_translucent = true;

        polkit_agent = true;
        password_style = "random";

        launch_apps_as_systemd_services = true;

        screen_time_enabled = true;

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

          show_app_actions = true;
        };

        panel = {
          borders = true;
          list_item_background = true;
          # floating panels at the same 0.8 as attached ones; "glass" hardcodes them to 0.55
          transparency_mode = "soft";

          clipboard_placement = "attached";
          control_center_placement = "attached";
          launcher_placement = "attached";
          session_placement = "attached";
          wallpaper_placement = "attached";

          clipboard_position = "auto";
          control_center_position = "top_center";
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
          remember_last_region = false;
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
                  command = ''foot sh -c "${rebuild.os "boot"} && systemctl reboot"'';
                  label = "Rebuild & Reboot";
                }
              )
              ((action "shutdown" "s") // { variant = "destructive"; })
            ];
        };

        shadow.alpha = 0.0;
      };
    };
}
