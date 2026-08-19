_:

{
  bar = {
    order = [ "default" ];

    default = {
      auto_hide = false;
      background_opacity = 0.8;
      border = "outline";
      border_width = 0.0;
      capsule = false;
      capsule_fill = "surface_variant";
      capsule_group = [ ];
      capsule_opacity = 1.0;
      capsule_padding = 6.0;
      capsule_radius = 4.0;
      capsule_thickness = 0.76;
      center = [
        "clock"
        "binary-clock"
      ];
      concave_edge_corners = true;
      contact_shadow = false;
      enabled = true;
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
      font_weight = 500;
      hover_highlight = true;
      layer = "top";
      margin_edge = 0;
      margin_ends = 50;
      margin_opposite_edge = 0;
      padding = 8;
      panel_overlap = 1;
      position = "top";
      radius = 4;
      radius_bottom_left = 4;
      radius_bottom_right = 4;
      radius_top_left = 4;
      radius_top_right = 4;
      reserve_space = true;
      scale = 1.0;
      shadow = true;
      show_on_workspace_switch = true;
      smart_auto_hide = false;
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
  };
}
