_:

{
  bar.default = {
    background_opacity = 0.8;
    border_width = 1.0;
    capsule = false;
    capsule_radius = 0.0;
    center = [
      "clock"
      "bar"
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
    font_family = "JetBrainsMono NF";
    margin_edge = 8;
    margin_ends = 8;
    padding = 8;
    position = "left";
    radius = 0;
    start = [
      "workspaces"
      "nix-monitor"
      "media"
      "audio_visualizer"
    ];
    thickness = 32;
    widget_spacing = 12;

    dead_zone.actions = {
      scroll_up = "workspace-switch prev";
      scroll_down = "workspace-switch next";
    };
  };
}
