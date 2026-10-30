{
  flake.modules.homeManager.noctalia.programs.noctalia.settings.bar.default = {
    thickness = 25;

    radius = 0;
    capsule_radius = 0;
    capsule_thickness = 1;
    concave_edge_corners = false;
    shadow = false;

    margin_ends = 0;
    widget_spacing = 10;

    start = [
      "cat"
      "audio_visualizer"
      "media"
      "active_window"
    ];

    center = [ "workspaces" ];

    end = [
      "tray"
      "sysmon"
      "nix_monitor"
      "network"
      "bluetooth"
      "volume"
      "brightness"
      "notifications"
      "battery"
      "date"
      "clock"
    ];
  };
}
