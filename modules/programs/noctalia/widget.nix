{
  flake.modules.homeManager.noctalia.programs.noctalia.settings.widget = {
    active_window = {
      show_empty_label = true;
      title_scroll = "on_hover";
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

    screen_toolkit.type = "alexander/screen-toolkit:widget";

    network.show_label = false;
    volume.show_label = false;
    workspaces = {
      show_tooltip = false;
      style = "minimal";
    };

    tray = {
      detached_panel = false;
      drawer = true;
    };

    nix_monitor = {
      update_available_color = "error";
      checking_color = "secondary";
      up_to_date_color = "primary";
      show_text = false;
      type = "avivbintangaringga/nix-monitor:nix-monitor";
    };
  };
}
