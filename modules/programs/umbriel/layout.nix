{
  flake.modules.homeManager.umbriel.programs.umbriel.settings = {
    layout = {
      mode = "scrolling";
      gap = 8;

      width_presets = [
        0.33333
        0.5
        0.66667
      ];

      scrolling = {
        default_width_fraction = 0.5;
        center_underfull_strip = true;
      };
    };

    workspace = [
      {
        index = 10;
        layout.mode = "dwindle";
      }
    ];
  };
}
