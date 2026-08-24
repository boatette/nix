{ inputs, ... }:
let
  inherit (inputs.self.constants) flakeDir;
in
{
  flake.modules.homeManager.noctalia.programs.noctalia.settings.shell = {
    font_family = "sans-serif";
    date_format = "%A, %x";
    time_format = "{:%H:%M}";

    button_borders = false;
    card_borders = false;
    input_borders = false;
    popup_borders = false;
    popup_shadows = false;
    corner_radius_scale = 1.0;

    app_icon_colorize = false;
    avatar_path = "";
    disable_mipmaps = false;
    shared_gl_context = true;
    password_style = "default";

    polkit_agent = true;

    launch_apps_as_systemd_services = true;
    launch_apps_custom_command = "";

    clipboard_enabled = true;
    clipboard_auto_paste = "auto";
    clipboard_confirm_clear_history = true;
    clipboard_history_max_entries = 100;
    clipboard_image_action_command = "";
    clipboard_keep_from_closed_apps = true;

    external_ip_enabled = false;
    offline_mode = false;
    telemetry_enabled = false;
    show_location = true;
    screen_time_enabled = true;

    settings_show_advanced = true;
    settings_window_translucent = true;
    setup_wizard_enabled = true;

    animation = {
      enabled = true;
      speed = 1.0;
    };

    greeter_sync = {
      auto_sync = true;
      privilege_command = "pkexec";
    };

    keyboard_layout = { };

    launcher = {
      app_grid = true;
      auto_paste = "auto";
      categories = true;
      compact = false;
      fetch_exchange_rates = true;
      pinned = [ ];
      provider_prefix = "/";
      show_app_actions = false;
      show_icons = true;
      sort_by_usage = true;

      dmenu = { };

      providers = {
        calculator.prefix = "=";
        emoji.prefix = ":";
        wallpaper.prefix = "";
        windows.prefix = "@";
      };
    };

    mpris.blacklist = [ ];

    panel = {
      borders = false;
      shadow = true;
      transparency_mode = "glass";
      list_item_background = true;

      floating_layer = "overlay";
      floating_offset = 8;

      clipboard_placement = "floating";
      clipboard_position = "center";
      control_center_placement = "attached";
      control_center_position = "auto";
      launcher_placement = "attached";
      launcher_position = "center";
      polkit_placement = "floating";
      polkit_position = "center";
      session_placement = "attached";
      session_position = "top_center";
      wallpaper_placement = "attached";
      wallpaper_position = "top_center";

      open_near_click_clipboard = false;
      open_near_click_control_center = true;
      open_near_click_launcher = false;
      open_near_click_session = false;
      open_near_click_wallpaper = false;
    };

    privacy = {
      cam_filter_regex = "";
      mic_filter_regex = "";
      screen_filter_regex = "";
    };

    screen_corners = {
      enabled = false;
      size = 36;
    };

    screenshot = {
      directory = "~/Pictures/Screenshots";
      filename_pattern = "Screenshot from %Y-%m-%d %H-%M-%S";
      confirm_region = true;
      copy_to_clipboard = true;
      save_to_file = true;
      freeze_screen = true;
      remember_last_region = true;
      show_cursor = false;
      pipe_to_command = false;
      pipe_command = "";
    };

    session = {
      grid = true;
      grid_columns = 3;
      show_shortcuts = true;
      power = { };

      actions =
        let
          action = name: shortcut: variant: {
            action = name;
            inherit shortcut variant;
            command = "";
            countdown_seconds = 0.0;
            enabled = true;
            glyph = "";
            label = "";
          };
        in
        [
          (action "lock" "l" "default")
          (action "lock_and_suspend" "u" "default")
          (action "logout" "e" "default")
          (action "reboot" "r" "default")
          (
            (action "command" "b" "default")
            // {
              command = ''ghostty -- sh -c "run0 nixos-rebuild boot --flake ${flakeDir} && systemctl reboot"'';
              label = "Rebuild & Reboot";
            }
          )
          (action "shutdown" "s" "destructive")
        ];
    };

    shadow = {
      alpha = 0.55;
      direction = "down";
    };
  };
}
