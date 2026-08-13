{ inputs, ... }:

{
  flake.modules.homeManager.desktop = {
    imports = [ inputs.selector.homeModules.selector ];

    programs.selector = {
      enable = true;

      settings = {
        layer = "bottom";

        border_width = 1;

        drag_threshold = 4.0;

        colors = "noctalia.toml";
      };
    };
  };
}
