{
  flake.modules.homeManager.noctalia =
    { config, ... }:
    {
      programs.noctalia.settings.bar.default = {
        position = "top";

        thickness = 32;

        font_family = config.constants.fonts.mono.name;

        background_opacity = 0.8;

        radius = 0;

        padding = 10;
        widget_spacing = 12;
        margin_ends = 50;

        capsule_radius = 4.0;

        start = [
          "cat"
          "nix-monitor"
          "umbriel-companion"
          "audio_visualizer"
          "media"
        ];

        center = [
          "workspaces"
        ];

        end = [
          "tray"
          "network"
          "bluetooth"
          "volume"
          "notifications"
          "battery"
          "clipboard"
          "clock"
        ];

        dead_zone.actions = {
          scroll_up = "workspace-switch prev";
          scroll_down = "workspace-switch next";
        };
      };
    };
}
