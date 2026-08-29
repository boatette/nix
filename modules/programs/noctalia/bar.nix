{
  flake.modules.homeManager.noctalia =
    { config, ... }:
    {
      programs.noctalia.settings.bar.default = {
        position = "left";

        thickness = 32;

        font_family = config.constants.fonts.mono.name;

        background_opacity = 0.5;

        radius = 4;
        radius_bottom_left = 4;
        radius_bottom_right = 4;
        radius_top_left = 4;
        radius_top_right = 4;

        padding = 10;
        widget_spacing = 12;
        margin_ends = 6;

        capsule_radius = 4.0;

        start = [
          "cat"
          "nix-monitor"
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
