{
  lib,
  pkgs,
  monitors,
  homeDirectory,
  templates,
  primaryMonitor,
  loginBoxes,
  ...
}:

{
  shell = {
    corner_radius_scale = 0.0;
    launch_apps_as_systemd_services = true;
    niri_overview_type_to_launch_enabled = true;
    polkit_agent = true;
    popup_shadows = false;
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
      control_center_placement = "floating";
      launcher_placement = "floating";
      list_item_background = true;
      open_near_click_control_center = true;
      session_placement = "floating";
      session_position = "top_center";
      transparency_mode = "glass";
      wallpaper_placement = "floating";
      wallpaper_position = "top_center";
    };

    screen_corners = {
      enabled = false;
      size = 36;
    };

    screenshot = {
      directory = "~/Pictures/Screenshots";
      filename_pattern = "Screenshot from %Y-%m-%d %H-%M-%S";
    };

    session.actions = [
      {
        action = "lock";
        shortcut = "l";
        variant = "default";
      }
      {
        action = "logout";
        shortcut = "e";
        variant = "default";
      }
      {
        action = "lock_and_suspend";
        shortcut = "u";
        variant = "default";
      }
      {
        action = "reboot";
        shortcut = "r";
        variant = "default";
      }
      {
        action = "shutdown";
        shortcut = "s";
        variant = "destructive";
      }
    ];
  };

  audio.enable_sounds = true;

  backdrop.enabled = false;

  brightness.sync_all_monitors = true;

  calendar = {
    enabled = true;

    account.personal_google = {
      name = "Personal Calendar";
      type = "google";
    };
  };

  config = { };

  control_center = {
    show_shortcut_labels = false;
    sidebar_section = "none";
    width = 800;

    calendar.show_week_numbers = true;
  };

  idle = {
    behavior_order = [
      "lock"
      "screen-off"
      "lock-and-suspend"
    ];

    behavior = {
      lock = {
        action = "lock";
        enabled = true;
        timeout = 600.0;
      };

      lock-and-suspend = {
        action = "lock_and_suspend";
        enabled = true;
        timeout = 900.0;
      };

      screen-off = {
        action = "screen_off";
        enabled = true;
        timeout = 660.0;
      };
    };
  };

  keybinds = {
    down = [
      "Down"
      "Ctrl+j"
    ];
    left = [
      "Left"
      "Ctrl+h"
    ];
    right = [
      "Right"
      "Ctrl+l"
    ];
    tab_next = [
      "Tab"
      "Ctrl+n"
    ];
    tab_previous = [
      "Shift+ISO_Left_Tab"
      "Ctrl+p"
    ];
    up = [
      "Up"
      "Ctrl+k"
    ];
  };

  location.auto_locate = true;

  osd = {
    position = "bottom_center";
    position_vertical = "center_left";
  };

  wallpaper.transition_on_startup = true;
}
