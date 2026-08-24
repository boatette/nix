{
  flake.modules.homeManager.umbriel.programs.umbriel.settings.appearance = {
    border_width = 1;
    outer_border_width = 1;
    corner_radius = 4;

    blur = {
      passes = 4;
      radius = 6;
      noise = 0.03;
      saturation = 1.0;
    };

    shadow = {
      enabled = false;
      offset_x = 0;
      offset_y = 0;
    };
  };
}
