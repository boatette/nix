{
  flake.modules.homeManager.noctalia.programs.noctalia.settings.widget = {
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
    volume.show_label = false;
    tray.drawer = true;

    nix-monitor = {
      show_text = false;
      type = "avivbintangaringga/nix-monitor:nix-monitor";
    };

    workspaces.style = "minimal";
  };
}
