{
  flake.modules.homeManager.noctalia =
    { config, ... }:
    {
      programs.noctalia.settings.bar.default = {
        position = "left";

        thickness = 32;

        font_family = config.constants.fonts.mono.name;

        background_opacity = 0.8;

        radius = 0;

        padding = 10;
        widget_spacing = 12;
        margin_ends = 0;

        capsule_radius = 0.0;

        start = [
          "umbriel-companion"
          "workspaces"
          "audio_visualizer"
          "media"
        ];

        center = [
          "clock"
        ];

        end = [
          "tray"
          "nix-monitor"
          "network"
          "bluetooth"
          "volume"
          "notifications"
          "battery"
          "clipboard"
          "cat"
        ];

        dead_zone.actions = {
          scroll_up = "workspace-switch prev";
          scroll_down = "workspace-switch next";
        };
      };
    };
}
