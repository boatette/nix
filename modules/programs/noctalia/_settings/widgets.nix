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
  desktop_widgets = {
    schema_version = 2;
    widget_order = [ "desktop-widget-0000000000000001" ];
    grid = {
      cell_size = 16;
      major_interval = 4;
      visible = true;
    };
    widget = {
      desktop-widget-0000000000000001 = {
        box_height = 240.0;
        box_width = 432.0;
        cx = 265.0;
        cy = 953.0;
        output = primaryMonitor;
        rotation = 0.0;
        type = "boatette/binary-clock:desktop";

        settings = {
          background_radius = 0;
          show_digits = false;
          show_headers = false;
          show_labels = false;
          show_separators = false;
        };
      };
    };
  };

  widget = {
    bar = {
      enabled = false;
      type = "boatette/binary-clock:bar";
    };
    battery = {
      hide_when_full = true;
      hide_when_plugged = true;
    };
    bluetooth.hide_when_no_connected_device = true;
    cat.type = "dotnetrob/cat:cat";
    launcher.custom_image_colorize = true;
    media = {
      hide_when_no_media = true;
      title_scroll = "always";
    };
    network.show_label = false;
    nix-monitor = {
      show_text = false;
      type = "avivbintangaringga/nix-monitor:nix-monitor";
    };
    tray.drawer = true;
    volume.show_label = false;
    workspaces = {
      labels_only_when_occupied = true;
      # style = "minimal";
    };
  };
}
