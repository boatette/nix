{ inputs, lib, ... }:
{
  flake.modules.homeManager.umbriel.programs.umbriel.settings = {
    layout = {
      scrolling.default_width_fraction = 0.5;
    };

    workspace = [
      {
        index = 10;
        layout.mode = "dwindle";
      }
    ]
    ++
      lib.concatMap
        (
          output:
          map (index: {
            inherit output index;
            layout.scrolling.direction = "vertical";
          }) (lib.range 1 10)
        )
        (
          lib.attrNames (
            lib.filterAttrs (
              _: m:
              lib.elem (toString (m.transform or "normal")) [
                "90"
                "270"
                "flipped-90"
                "flipped-270"
              ]
            ) inputs.self.monitors
          )
        );
  };
}
