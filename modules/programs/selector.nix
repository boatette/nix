{ inputs, ... }:

{
  flake.modules.homeManager.desktop = {
    imports = [ inputs.selector.homeModules.selector ];

    programs.selector = {
      enable = true;

      settings = {
        blur = true;
        corner_radius = 4;

        colors = "noctalia.toml";
      };
    };
  };
}
