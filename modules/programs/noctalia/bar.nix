{
  flake.modules.homeManager.noctalia.programs.noctalia.settings.bar.default = {
    thickness = 25;

    background_opacity = 0.8;

    radius = 12;
    capsule_thickness = 1;
    concave_edge_corners = true;
    shadow = false;

    margin_ends = 260;
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
