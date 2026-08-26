{ inputs, ... }:
{
  flake-file.inputs.selector = {
    url = "github:boatette/selector";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager = {
    selector = {
      imports = [ inputs.selector.homeModules.selector ];

      programs.selector = {
        enable = true;

        settings = {
          blur = true;
          corner_radius = 4;
          layer = "background";

          colors = "noctalia.toml";
        };
      };
    };

    umbriel.programs.umbriel.settings.layer_rule = [
      {
        match.namespace = "^selector$";
        blur = true;
        blur_ignore_alpha = 0.05;
        blur_optimized = false;
      }
    ];
  };
}
