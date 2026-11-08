{
  flake.modules.homeManager.noctalia =
    { config, ... }:
    {
      programs.noctalia.settings.osd = {
        background_opacity = config.constants.glass.opacity;
        position = "bottom_center";

        # clears the dock, which is 68 tall, by umbriel's gap
        offset_y = 68 + config.programs.umbriel.settings.layout.gap;
      };
    };
}
