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

        margin_ends = 600;
        widget_spacing = 10;

        # 1080 wide when monitor-autorotate turns it portrait, too narrow for the 600 above
        monitor."HDMI-A-1".margin_ends = 180;

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
