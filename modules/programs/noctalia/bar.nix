{ inputs, lib, ... }:
{
  flake.modules.homeManager.boatette =
    let
      inherit (inputs.self.constants.glass) radius opacity;
      inherit (inputs.self.lib) isPortrait monitorProfiles;

      turnsPortrait = name: lib.any (layout: isPortrait layout.${name}) (lib.attrValues monitorProfiles);
    in
    {
      programs.noctalia.settings.bar.default = {
        thickness = 32;

        background_opacity = opacity;

        inherit radius;
        capsule_thickness = 0.75;

        margin_ends = 600;
        widget_spacing = 10;

        # a portrait 1080 is too narrow for the 600 above
        monitor = lib.mapAttrs (_: _: { margin_ends = 180; }) (
          lib.filterAttrs (name: _: turnsPortrait name) inputs.self.monitors
        );

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
