{
  flake.modules.homeManager.noctalia.programs.noctalia.settings.widget = {
    battery = {
      hide_when_full = false;
      hide_when_plugged = false;
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
    tray = {
      detached_panel = true;
      drawer = true;
    };

    nix-monitor = {
      update_available_color = "error";
      checking_color = "secondary";
      up_to_date_color = "primary";
      show_text = false;
      type = "avivbintangaringga/nix-monitor:nix-monitor";
    };

    tailnet = {
      type = "rylos/tailnet:bar";
      panel_placement = "floating";
    };

    recorder.type = "noctalia/screen_recorder:recorder";

    umbriel-companion.type = "noctalia/umbriel-companion:bar";

    # Mimic dwl-style tags: square full-height cells, the focused one on overlay
    # (surface_container) with text, the rest on base (surface).
    workspaces = {
      style = "regular";
      capsule = false;
      capsule_radius = 0;

      # Labels are 11px where other bar text is 14px; this multiplies the
      # bar's font_scale, so they land on the same 16px.
      font_scale = 14.0 / 11.0;
      # a dwl tag cell is digit + font height wide, ~31px.
      active_pill_size = 1.35;
      inactive_pill_size = 1.35;

      focused_color = "surface_container";
      occupied_color = "surface";
      empty_color = "surface";
    };
  };
}
