{
  flake.modules.homeManager.noctalia =
    { config, ... }:
    {
      programs.noctalia.settings.osd = {
        border = true;

        background_opacity = config.constants.glass.opacity;
        position = "bottom_center";
        position_vertical = "center_left";

        # clears the dock, which is 68 tall, by niri's gaps
        offset_y = 76;
      };
    };
}
