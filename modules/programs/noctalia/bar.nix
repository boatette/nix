{
  flake.modules.homeManager.noctalia =
    { config, ... }:
    let
      inherit (config.constants.glass) radius opacity;
    in
    {
      programs.noctalia.settings.bar.default = {
        thickness = 25;

        background_opacity = opacity;

        inherit radius;
        capsule_thickness = 1;
        concave_edge_corners = true;

        shadow = true;
        contact_shadow = true;

        margin_ends = 260;
        widget_spacing = 10;

        start = [
          "workspaces"
          "active_window"
        ];

        center = [
          "media"
          "clock"
          "audio_visualizer"
        ];

        end = [
          "tray"
          "cat"
          "nix_monitor"
          "screen_toolkit"
          "network"
          "bluetooth"
          "volume"
          "notifications"
          "battery"
          "date"
        ];
      };
    };
}
