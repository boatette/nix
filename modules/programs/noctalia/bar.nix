{
  flake.modules.homeManager.noctalia =
    { config, ... }:
    {
      programs.noctalia.settings.bar.default = {
        position = "top";

        reserve_space = true;
        smart_auto_hide = false;

        # a dwl-style bar, like aion's: font height + 2px, at 12pt/96dpi JetBrainsMono.
        thickness = 23;

        # Widget content (icons, workspace pills) is sized for a 16px glyph;
        # scale it up to fill the 23px bar.
        scale = 23.0 / 16.0;

        font_family = config.constants.fonts.mono.name;
        # fcft loads the Regular face; noctalia defaults to 500.
        font_weight = 400;
        # Text is 14px * scale * font_scale; bring it back to 16px (12pt).
        font_scale = 16.0 / (14.0 * 23.0 / 16.0);
        color = "on_surface_variant";

        background_opacity = 1.0;

        radius = 0;

        padding = 0;
        widget_spacing = 12;
        margin_ends = 0;
        margin_edge = 0;

        border_width = 0.0;

        capsule = false;
        capsule_radius = 0.0;
        capsule_padding = 3.0;
        capsule_thickness = 1.0;

        start = [
          "workspaces"
          "audio_visualizer"
          "audio_visualizer"
        ];

        center = [ ];

        end = [
          "nix-monitor"
          "cat"
          "battery"
          "date"
          "clock"
        ];
      };
    };
}
