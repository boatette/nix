{
  flake.modules.homeManager.noctalia =
    { config, ... }:
    let
      inherit (config.programs.umbriel.settings) layout;
    in
    {
      programs.noctalia.settings.notification = {
        background_opacity = config.constants.glass.opacity;

        # in line with the edge of the windows
        offset_x = layout.struts.right + layout.gap;
      };
    };
}
