{ inputs, ... }:
{
  flake.modules.homeManager.umbriel.programs.umbriel.settings.appearance = {
    border_width = 1;
    outer_border_width = 0;
    corner_radius = inputs.self.constants.glass.radius;

    prefer_no_csd = true;
    title_bar.mode = "off";

    blur = {
      enabled = true;
      optimized = true;
      passes = 2;
      radius = 3;
      noise = 0.02;
      brightness = 0.9;
      contrast = 0.9;
      saturation = 1.1;
    };

    shadow = {
      enabled = true;
      offset_x = 0;
      offset_y = 4;
      softness = 20;
    };

    tab_bar = {
      height = 8;
      style = "indicator";
      position = "left";
    };
  };
}
