{
  flake.modules.homeManager.niri =
    { config, ... }:
    let
      inherit (config.constants) palette;

      proportion = p: { proportion = p; };
    in
    {
      wayland.windowManager.niri.settings.layout = {
        gaps = 8;
        struts = {
          left = 20;
          right = 20;
        };

        default-column-width = proportion 0.5;
        preset-column-widths._children = map proportion [
          (1.0 / 3.0)
          0.5
          (2.0 / 3.0)
        ];

        focus-ring.off = { };
        border = {
          on = { };
          width = 1;
          active-color = "#${palette.rose}";
          inactive-color = "#${palette.muted}";
          urgent-color = "#${palette.love}";
        };

        # the wallpaper sits in the backdrop, so workspaces must be see-through to show it
        background-color = "transparent";
      };
    };
}
