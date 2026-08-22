{ inputs, ... }:
{
  flake.modules.homeManager.noctalia.programs.noctalia.settings.widget = {
    active_window = {
      type = "active_window";
      icon_size = 14.0;
      max_length = 260.0;
      min_length = 80.0;
      title_scroll = "none";
    };

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

    date = {
      type = "clock";
      format = "{:%a %d %b}";
    };

    keyboard_layout = {
      type = "keyboard_layout";
      hide_when_single_layout = false;
    };

    launcher.custom_image_colorize = true;

    lock_keys = {
      type = "lock_keys";
      display = "short";
      hide_when_off = false;
      show_caps_lock = true;
      show_num_lock = true;
      show_scroll_lock = false;
    };

    media = {
      type = "media";
      art_size = 16.0;
      hide_when_no_media = true;
      max_length = 220.0;
      min_length = 80.0;
      title_scroll = "always";
    };

    network.show_label = false;
    volume.show_label = false;
    tray.drawer = true;

    input_volume = {
      type = "volume";
      device = "input";
    };

    output_volume = {
      type = "volume";
      device = "output";
    };

    nix-monitor = {
      type = "avivbintangaringga/nix-monitor:nix-monitor";
      show_text = false;
    };

    spacer = {
      type = "spacer";
      interactive = false;
    };

    workspaces = {
      hide_when_empty = true;
      labels_only_when_occupied = true;
    };

    cpu = {
      type = "sysmon";
      stat = "cpu_usage";
    };
    temp = {
      type = "sysmon";
      stat = "cpu_temp";
    };
    ram = {
      type = "sysmon";
      stat = "ram_used";
    };
    network_rx = {
      type = "sysmon";
      stat = "net_rx";
    };
    network_tx = {
      type = "sysmon";
      stat = "net_tx";
    };
  };

  flake.modules.homeManager.noctalia.programs.noctalia.settings.desktop_widgets =
    let
      monitors = inputs.self.monitors;
      names = builtins.attrNames monitors;
      primary = builtins.head (builtins.filter (n: monitors.${n}.primary or false) names ++ names);
    in
    {
      enabled = true;
      schema_version = 2;
      widget_order = [ "desktop-widget-0000000000000001" ];

      grid = {
        cell_size = 16;
        major_interval = 4;
        visible = true;
      };

      widget.desktop-widget-0000000000000001 = {
        type = "boatette/binary-clock:desktop";
        output = primary;

        box_height = 240.0;
        box_width = 432.0;
        cx = 265.0;
        cy = 953.0;
        rotation = 0.0;

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
