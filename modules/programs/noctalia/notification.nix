{
  flake.modules.homeManager.noctalia =
    { config, ... }:
    {
      programs.noctalia.settings.notification = {
        border = true;

        background_opacity = config.constants.glass.opacity;

        # umbriel's struts + gaps, to line up with the edge of the windows
        offset_x = 28;

        filter_order = [ "filter" ];

        filter.rmpc = {
          enabled = true;
          match = "rmpc";

          allow_permanent = false;
          bypass_dnd = false;
          play_sound = false;
          save_history = false;
          show_toast = false;
        };
      };
    };
}
