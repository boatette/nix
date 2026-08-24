{ inputs, ... }:
{
  flake.modules.homeManager.noctalia.programs.noctalia.settings.widget = {
    battery = {
      hide_when_full = true;
      hide_when_plugged = true;
    };

    binary-clock = {
      type = "boatette/binary-clock:bar";
      enabled = false;
    };

    bluetooth.hide_when_no_connected_device = true;
    cat.type = "dotnetrob/cat:cat";

    launcher.custom_image_colorize = true;

    media = {
      hide_when_no_media = true;
      title_scroll = "always";
    };

    network.show_label = false;
    volume.show_label = false;
    tray.drawer = true;

    nix-monitor = {
      type = "avivbintangaringga/nix-monitor:nix-monitor";
      show_text = false;
    };

    umbriel-layout = {
      type = "boatette/umbriel-layout:bar";
      display_mode = "icon";
    };

    workspaces = {
      hide_when_empty = true;
      labels_only_when_occupied = true;
    };
  };

  flake.modules.homeManager.noctalia.programs.noctalia.settings.desktop_widgets =
    let
      monitors = inputs.self.monitors;
      names = builtins.attrNames monitors;
      primary = builtins.head (builtins.filter (n: monitors.${n}.primary or false) names ++ names);
    in
    {
      widget_order = [ "desktop-widget-0000000000000001" ];

      widget.desktop-widget-0000000000000001 = {
        type = "boatette/binary-clock:desktop";
        output = primary;

        box_height = 240.0;
        box_width = 432.0;
        cx = 226.0;
        cy = 950.0;

        settings = {
          background_radius = 4;
          show_digits = false;
          show_headers = false;
          show_labels = false;
          show_separators = false;
        };
      };
    };
}
