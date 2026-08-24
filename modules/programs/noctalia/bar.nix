{
  flake.modules.homeManager.noctalia.programs.noctalia.settings.bar.default = {
    thickness = 32;

    font_family = "JetBrainsMono NF";

    background_opacity = 0.8;

    radius = 4;
    radius_bottom_left = 4;
    radius_bottom_right = 4;
    radius_top_left = 4;
    radius_top_right = 4;

    padding = 8;
    widget_spacing = 12;
    margin_ends = 8;

    capsule_radius = 4.0;

    start = [
      "workspaces"
      "umbriel-layout"
      "nix-monitor"
      "audio_visualizer"
      "media"
    ];

    center = [
      "clock"
      "binary-clock"
    ];

    end = [
      "tray"
      "network"
      "bluetooth"
      "volume"
      "notifications"
      "battery"
      "cat"
    ];

    dead_zone.actions = {
      scroll_up = "workspace-switch prev";
      scroll_down = "workspace-switch next";
    };
  };
}
