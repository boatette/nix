{
  flake.modules.homeManager.umbriel.programs.umbriel.settings = {
    appearance = {
      prefer_no_csd = true;

      border_width = 1;
      outer_border_width = 1;
      corner_radius = 4;

      blur = {
        enabled = true;
        optimized = true;
        passes = 4;
        radius = 6;
        noise = 0.03;
        brightness = 0.9;
        contrast = 0.9;
        saturation = 1.0;
      };

      shadow = {
        enabled = false;
        softness = 10;
        offset_x = 0;
        offset_y = 0;
      };
    };

    overview.zoom = 0.5;
  };
}
