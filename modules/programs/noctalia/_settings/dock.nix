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
  dock = {
    border_width = 1.0;
    concave_edge_corners = false;
    enabled = true;
    icon_size = 40;
    margin_edge = 8;
    pinned = [
      "footclient"
      "zen-beta"
      "vesktop"
      "steam"
      "org.prismlauncher.PrismLauncher"
      "com.stremio.Stremio"
      "org.kde.dolphin"
    ];
    radius = 0;
    reserve_space = false;
    show_dots = true;
    show_instance_count = false;
    smart_auto_hide = true;
  };
}
