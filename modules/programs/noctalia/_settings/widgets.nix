{
  primaryMonitor,
  ...
}:

{
  desktop_widgets = {
    enabled = true;
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
          background_radius = 4;
          show_digits = false;
          show_headers = false;
          show_labels = false;
          show_separators = false;
        };
      };
    };
  };

  widget = {
    active_window = {
      icon_size = 14.0;
      max_length = 260.0;
      min_length = 80.0;
      title_scroll = "none";
      type = "active_window";
    };
    battery = {
      hide_when_full = true;
      hide_when_plugged = true;
    };
    binary-clock = {
      enabled = false;
      type = "boatette/binary-clock:bar";
    };
    bluetooth.hide_when_no_connected_device = true;
    cat.type = "dotnetrob/cat:cat";
    cpu = {
      stat = "cpu_usage";
      type = "sysmon";
    };
    date = {
      format = "{:%a %d %b}";
      type = "clock";
    };
    input_volume = {
      device = "input";
      type = "volume";
    };
    keyboard_layout = {
      hide_when_single_layout = false;
      type = "keyboard_layout";
    };
    launcher.custom_image_colorize = true;
    lock_keys = {
      display = "short";
      hide_when_off = false;
      show_caps_lock = true;
      show_num_lock = true;
      show_scroll_lock = false;
      type = "lock_keys";
    };
    media = {
      art_size = 16.0;
      hide_when_no_media = true;
      max_length = 220.0;
      min_length = 80.0;
      title_scroll = "always";
      type = "media";
    };
    network.show_label = false;
    network_rx = {
      stat = "net_rx";
      type = "sysmon";
    };
    network_tx = {
      stat = "net_tx";
      type = "sysmon";
    };
    nix-monitor = {
      show_text = false;
      type = "avivbintangaringga/nix-monitor:nix-monitor";
    };
    output_volume = {
      device = "output";
      type = "volume";
    };
    ram = {
      stat = "ram_used";
      type = "sysmon";
    };
    spacer = {
      interactive = false;
      type = "spacer";
    };
    temp = {
      stat = "cpu_temp";
      type = "sysmon";
    };
    tray.drawer = true;
    volume.show_label = false;
    workspaces = {
      labels_only_when_occupied = true;
      # style = "minimal";
    };
  };
}
