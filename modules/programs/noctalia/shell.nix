{ inputs, ... }:
{
  flake.modules.homeManager.noctalia =
    { config, ... }:
    let
      inherit (config.constants) flakeDir fonts;

      rebuild = inputs.self.lib.rebuild flakeDir;
    in
    {
      programs.noctalia.settings.shell = {
        font_family = fonts.mono.name;

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
          providers = {
            calculator.prefix = "=";
            emoji.prefix = ":";
            wallpaper.prefix = "";
            windows.prefix = "@";
          };

          show_app_actions = true;
        };

        panel = {
          list_item_background = true;
          transparency_mode = "soft";

          control_center_placement = "floating";
          session_placement = "floating";
          wallpaper_placement = "floating";

          control_center_position = "top_center";
          session_position = "top_center";
          wallpaper_position = "top_center";

          open_near_click_clipboard = true;
          open_near_click_control_center = true;
        };

        screenshot = {
          directory = "~/Pictures/Screenshots";
          filename_pattern = "Screenshot from %Y-%m-%d %H-%M-%S";
          confirm_region = true;
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
                  label = "Rebuild-boot";
                }
              )
              ((action "shutdown" "s") // { variant = "destructive"; })
            ];
        };

        shadow.alpha = 0.0;
      };
    };
}
