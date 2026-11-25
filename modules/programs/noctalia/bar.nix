{ inputs, ... }:
{
  flake.modules.homeManager.boatette =
    let
      inherit (inputs.self.constants.glass) radius opacity;
    in
    {
      programs.noctalia.settings.bar.default = {
        thickness = 32;

        background_opacity = opacity;

        inherit radius;
        capsule_thickness = 0.75;

        margin_ends = 600;
        widget_spacing = 10;

        # the arm turned portrait is 1080 wide, too narrow for the 600 above
        monitor.${inputs.self.constants.monitors.arm}.margin_ends = 180;

        layer = "auto";

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
          "tailnet"
          "noctaproton_vpn"
          "localsend_plus"
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
