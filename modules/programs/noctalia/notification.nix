{
  flake.modules.homeManager.boatette =
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
