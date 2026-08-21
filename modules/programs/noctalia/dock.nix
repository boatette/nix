{
  flake.modules.homeManager.noctalia.programs.noctalia.settings.dock = {
    enabled = true;
    position = "bottom";
    layer = "top";

    reserve_space = false;
    auto_hide = false;
    smart_auto_hide = true;

    icon_size = 40;
    item_spacing = 6;
    magnification = true;
    magnification_scale = 1.45;

    active_monitor_only = false;
    active_opacity = 1.0;
    active_scale = 1.0;
    inactive_opacity = 0.85;
    inactive_scale = 0.85;

    background_opacity = 0.88;
    border = "outline";
    border_width = 0.0;
    concave_edge_corners = true;
    shadow = true;

    radius = 4;
    radius_bottom_left = 4;
    radius_bottom_right = 4;
    radius_top_left = 4;
    radius_top_right = 4;

    cross_axis_padding = 8;
    main_axis_padding = 16;
    margin_edge = 0;
    margin_ends = 0;

    monitors = [ ];

    launcher_position = "none";
    launcher_icon = "grid-dots";
    launcher_custom_image = "";
    launcher_custom_image_colorize = false;

    show_dots = true;
    show_running = true;
    show_instance_count = false;

    pinned = [
      "footclient"
      "zen-beta"
      "vesktop"
      "steam"
      "org.prismlauncher.PrismLauncher"
      "com.stremio.Stremio"
      "org.kde.dolphin"
    ];
  };
}
