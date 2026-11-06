{
  flake.modules.homeManager.noctalia =
    { config, ... }:
    let
      inherit (config.constants.glass) radius opacity;
    in
    {
      programs.noctalia.settings.bar.default = {
        thickness = 32;

        background_opacity = opacity;

        inherit radius;
        capsule_thickness = 0.75;
        concave_edge_corners = true;

        shadow = true;
        contact_shadow = true;

        margin_ends = 600;
        widget_spacing = 10;

        start = [
          "workspaces"
          "umbriel_companion"
        ];

        center = [
          "clock"
          "audio_visualizer"
          "weather"
        ];

        end = [
          "nix_monitor"
          "network"
          "bluetooth"
          "battery"
          "volume"
          "notifications"
          "tray"
        ];
      };
    };
}
