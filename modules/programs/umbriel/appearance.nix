{
  flake.modules.homeManager.umbriel.programs.umbriel.settings.appearance = {
    border_width = 1;
    outer_border_width = 1;
    corner_radius = 4;

    blur = {
      enabled = true;
      optimized = true;
      passes = 3;
      radius = 3;
      noise = 0.02;
      brightness = 0.9;
      contrast = 0.9;
      saturation = 1.1;
    };
  };
}
