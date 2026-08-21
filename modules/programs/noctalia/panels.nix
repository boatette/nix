{
  flake.modules.homeManager.noctalia.programs.noctalia.settings = {
    control_center = {
      width = 800;
      sidebar = "compact";
      sidebar_section = "none";
      hidden_tabs = [ ];
      show_session_button = true;
      show_shortcut_labels = false;

      calendar = {
        event_date_format = "%A %e %B";
        event_time_format = "%H:%M";
        show_events_card = true;
        show_week_numbers = true;
      };

      shortcuts = map (type: { inherit type; }) [
        "wifi"
        "bluetooth"
        "caffeine"
        "nightlight"
        "notification"
        "power_profile"
      ];
    };

    notification = {
      enable_daemon = true;
      layer = "top";
      position = "top_right";
      offset_x = 20;
      offset_y = 8;
      scale = 1.0;
      background_opacity = 0.97;
      border = false;
      collapse_on_dismiss = true;
      show_actions = true;
      show_app_name = true;
      max_visible = 0;
      history_retention_hours = 0;
      monitors = [ ];
    };

    osd = {
      enabled = true;
      position = "bottom_center";
      position_vertical = "center_left";
      orientation = "horizontal";
      offset_x = 20;
      offset_y = 8;
      scale = 1.0;
      background_opacity = 0.97;
      border = false;
      monitors = [ ];

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

    hot_corners = {
      enabled = false;
      delay_ms = 0;
    };
  };
}
