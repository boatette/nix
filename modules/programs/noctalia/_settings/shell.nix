_:

{
  shell = {
    app_icon_colorize = false;
    avatar_path = "";
    button_borders = true;
    card_borders = true;
    clipboard_auto_paste = "auto";
    clipboard_confirm_clear_history = true;
    clipboard_enabled = true;
    clipboard_history_max_entries = 100;
    clipboard_image_action_command = "";
    clipboard_keep_from_closed_apps = true;
    corner_radius_scale = 0.0;
    date_format = "%A, %x";
    disable_mipmaps = false;
    external_ip_enabled = false;
    font_family = "sans-serif";
    input_borders = true;
    launch_apps_as_systemd_services = true;
    launch_apps_custom_command = "";
    niri_overview_type_to_launch_enabled = true;
    offline_mode = false;
    password_style = "default";
    polkit_agent = true;
    popup_borders = true;
    popup_shadows = false;
    screen_time_enabled = true;
    settings_show_advanced = true;
    settings_window_translucent = true;
    setup_wizard_enabled = true;
    shared_gl_context = true;
    show_location = true;
    telemetry_enabled = false;
    time_format = "{:%H:%M}";

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
      borders = true;
      clipboard_placement = "floating";
      clipboard_position = "center";
      control_center_placement = "floating";
      control_center_position = "auto";
      floating_layer = "overlay";
      floating_offset = 8;
      launcher_placement = "floating";
      launcher_position = "center";
      list_item_background = true;
      open_near_click_clipboard = false;
      open_near_click_control_center = true;
      open_near_click_launcher = false;
      open_near_click_session = false;
      open_near_click_wallpaper = false;
      polkit_placement = "floating";
      polkit_position = "center";
      session_placement = "floating";
      session_position = "top_center";
      shadow = true;
      transparency_mode = "glass";
      wallpaper_placement = "floating";
      wallpaper_position = "top_center";
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
      confirm_region = true;
      copy_to_clipboard = true;
      directory = "~/Pictures/Screenshots";
      filename_pattern = "Screenshot from %Y-%m-%d %H-%M-%S";
      freeze_screen = true;
      pipe_command = "";
      pipe_to_command = false;
      remember_last_region = true;
      save_to_file = true;
      show_cursor = false;
    };

    session = {
      grid = false;
      grid_columns = 3;
      show_shortcuts = true;

      power = { };

      actions = [
        {
          action = "lock";
          command = "";
          countdown_seconds = 0.0;
          enabled = true;
          glyph = "";
          label = "";
          shortcut = "l";
          variant = "default";
        }
        {
          action = "logout";
          command = "";
          countdown_seconds = 0.0;
          enabled = true;
          glyph = "";
          label = "";
          shortcut = "e";
          variant = "default";
        }
        {
          action = "lock_and_suspend";
          command = "";
          countdown_seconds = 0.0;
          enabled = true;
          glyph = "";
          label = "";
          shortcut = "u";
          variant = "default";
        }
        {
          action = "reboot";
          command = "";
          countdown_seconds = 0.0;
          enabled = true;
          glyph = "";
          label = "";
          shortcut = "r";
          variant = "default";
        }
        {
          action = "shutdown";
          command = "";
          countdown_seconds = 0.0;
          enabled = true;
          glyph = "";
          label = "";
          shortcut = "s";
          variant = "destructive";
        }
      ];
    };

    shadow = {
      alpha = 0.55;
      direction = "down";
    };
  };

  accessibility = {
    high_contrast = false;
    ui_scale = 1.0;
  };

  audio = {
    enable_overdrive = false;
    enable_sounds = true;
    notification_sound = "";
    sound_volume = 0.5;
    volume_change_sound = "";
  };

  backdrop = {
    blur_intensity = 0.5;
    enabled = false;
    tint_intensity = 0.3;
  };

  battery.warning_threshold = 10;

  brightness = {
    enable_ddcutil = false;
    ignore_mmids = [ ];
    minimum_brightness = 0.0;
    sync_all_monitors = true;
  };

  calendar = {
    enabled = true;
    refresh_minutes = 15;

    account.personal_google = {
      name = "Personal Calendar";
      type = "google";
    };
  };

  config = { };

  control_center = {
    hidden_tabs = [ ];
    show_session_button = true;
    show_shortcut_labels = false;
    sidebar = "compact";
    sidebar_section = "none";
    width = 800;

    calendar = {
      event_date_format = "%A %e %B";
      event_time_format = "%H:%M";
      show_events_card = true;
      show_week_numbers = true;
    };

    shortcuts = [
      { type = "wifi"; }
      { type = "bluetooth"; }
      { type = "caffeine"; }
      { type = "nightlight"; }
      { type = "notification"; }
      { type = "power_profile"; }
    ];
  };

  hot_corners = {
    delay_ms = 0;
    enabled = false;

    bottom_left = {
      action = "none";
      command = "";
    };
    bottom_right = {
      action = "none";
      command = "";
    };
    top_left = {
      action = "none";
      command = "";
    };
    top_right = {
      action = "none";
      command = "";
    };
  };

  idle = {
    pre_action_fade_seconds = 2.0;

    behavior_order = [
      "lock"
      "screen-off"
      "lock-and-suspend"
    ];

    behavior = {
      lock = {
        action = "lock";
        command = "";
        enabled = true;
        locked_timeout = 0.0;
        resume_command = "";
        timeout = 600.0;
      };

      lock-and-suspend = {
        action = "lock_and_suspend";
        command = "";
        enabled = true;
        locked_timeout = 0.0;
        resume_command = "";
        timeout = 900.0;
      };

      screen-off = {
        action = "screen_off";
        command = "";
        enabled = true;
        locked_timeout = 0.0;
        resume_command = "";
        timeout = 660.0;
      };
    };
  };

  keybinds = {
    cancel = [ "Escape" ];
    copy = [ "Ctrl+c" ];
    delete = [ "Delete" ];
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
    save = [ "Ctrl+s" ];
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
    validate = [
      "Return"
      "KP_Enter"
      "space"
    ];
  };

  location = {
    address = "";
    auto_locate = true;
    custom_schedule = false;
    sunrise = "";
    sunset = "";
  };

  nightlight = {
    enabled = false;
    force = false;
    temperature_day = 6500;
    temperature_night = 4000;
  };

  notification = {
    background_opacity = 0.97;
    border = true;
    collapse_on_dismiss = true;
    enable_daemon = true;
    history_retention_hours = 0;
    layer = "top";
    max_visible = 0;
    monitors = [ ];
    offset_x = 20;
    offset_y = 8;
    position = "top_right";
    scale = 1.0;
    show_actions = true;
    show_app_name = true;
  };

  osd = {
    background_opacity = 0.97;
    border = true;
    enabled = true;
    monitors = [ ];
    offset_x = 20;
    offset_y = 8;
    orientation = "horizontal";
    position = "bottom_center";
    position_vertical = "center_left";
    scale = 1.0;

    kinds = {
      bluetooth = true;
      brightness = true;
      caffeine = true;
      dnd = true;
      keyboard_backlight = true;
      keyboard_layout = true;
      lock_keys = true;
      media = true;
      nightlight = true;
      power_profile = true;
      privacy = true;
      volume = true;
      volume_input = true;
      volume_output = true;
      wifi = true;
    };
  };

  storage = {
    key_file = "";
    key_source = "secret-service";
  };

  system.monitor = {
    cpu_freq_activity_threshold = 2.5;
    cpu_freq_critical_threshold = 4.5;
    cpu_poll_seconds = 2.0;
    cpu_temp_activity_threshold = 60.0;
    cpu_temp_critical_threshold = 85.0;
    cpu_temp_sensor_path = "";
    cpu_usage_activity_threshold = 50.0;
    cpu_usage_critical_threshold = 90.0;
    disk_free_activity_threshold = 80.0;
    disk_free_critical_threshold = 95.0;
    disk_free_pct_activity_threshold = 80.0;
    disk_free_pct_critical_threshold = 95.0;
    disk_poll_seconds = 10.0;
    disk_used_activity_threshold = 80.0;
    disk_used_critical_threshold = 95.0;
    disk_used_pct_activity_threshold = 80.0;
    disk_used_pct_critical_threshold = 95.0;
    enabled = true;
    gpu_poll_seconds = 5.0;
    gpu_temp_activity_threshold = 60.0;
    gpu_temp_critical_threshold = 85.0;
    gpu_usage_activity_threshold = 50.0;
    gpu_usage_critical_threshold = 95.0;
    gpu_vram_activity_threshold = 50.0;
    gpu_vram_critical_threshold = 90.0;
    memory_poll_seconds = 2.0;
    net_rx_activity_threshold = 1.0;
    net_rx_critical_threshold = 50.0;
    net_tx_activity_threshold = 1.0;
    net_tx_critical_threshold = 50.0;
    network_poll_seconds = 3.0;
    ram_pct_activity_threshold = 60.0;
    ram_pct_critical_threshold = 90.0;
    swap_pct_activity_threshold = 20.0;
    swap_pct_critical_threshold = 80.0;
  };

  wallpaper = {
    directory = "";
    directory_dark = "";
    directory_light = "";
    edge_smoothness = 0.3;
    enabled = true;
    fill_color = "";
    fill_mode = "crop";
    per_monitor_directories = false;
    transition = [
      "fade"
      "wipe"
      "disc"
      "stripes"
      "zoom"
      "honeycomb"
    ];
    transition_duration = 1500.0;
    transition_on_startup = false;

    automation = {
      enabled = false;
      interval_seconds = 1800;
      order = "random";
      recursive = true;
    };
  };

  weather = {
    effects = true;
    enabled = true;
    refresh_minutes = 30;
    unit = "metric";
  };
}
