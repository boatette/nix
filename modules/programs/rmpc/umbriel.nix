{
  flake.modules.homeManager.umbriel.programs.umbriel.settings.window_rule = [
    {
      match.app_id = "^rmpc$";
      default_floating = true;
      default_scratchpad = "default";
      default_focused = true;
      opacity = 1.0;
      default_floating_size_px = {
        width = 1400;
        height = 800;
      };
      default_position = {
        x = 0;
        y = 40;
        anchor = "top";
      };
    }
  ];
}
