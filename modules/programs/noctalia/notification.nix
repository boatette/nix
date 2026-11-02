{
  flake.modules.homeManager.noctalia =
    { config, ... }:
    {
      programs.noctalia.settings.notification = {
        border = true;

        background_opacity = config.constants.glass.opacity;

        # niri's struts + gaps, to line up with the edge of the windows
        offset_x = 28;
      };
    };
}
