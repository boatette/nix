{
  flake.modules.homeManager.noctalia.programs.noctalia.settings.bar = {
    order = [ "default" ];

    default = {
      enabled = true;
      position = "top";
      layer = "top";
      thickness = 32;
      reserve_space = true;
      scale = 1.0;

      font_family = "JetBrainsMono NF";
      font_weight = 500;

      background_opacity = 0.8;
      border = "outline";
      border_width = 0.0;
      concave_edge_corners = true;
      shadow = true;
      contact_shadow = false;
      hover_highlight = true;

      radius = 4;
      radius_bottom_left = 4;
      radius_bottom_right = 4;
      radius_top_left = 4;
      radius_top_right = 4;

      padding = 8;
      widget_spacing = 12;
      margin_edge = 0;
      margin_ends = 8;
      margin_opposite_edge = 0;
      panel_overlap = 1;

      auto_hide = false;
      smart_auto_hide = false;
      show_on_workspace_switch = true;

      capsule = false;
      capsule_fill = "surface_variant";
      capsule_group = [ ];
      capsule_opacity = 1.0;
      capsule_padding = 6.0;
      capsule_radius = 4.0;
      capsule_thickness = 0.76;

      start = [
        "workspaces"
        "umbriel-layout"
        "nix-monitor"
        "media"
        "audio_visualizer"
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
  };
}
