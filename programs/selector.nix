{ inputs, ... }:

{
  flake.modules.homeManager.desktop = {
    imports = [ inputs.selector.homeModules.selector ];

    programs.selector = {
      enable = true;

      settings = {
        blur = true;

        colors = "noctalia.toml";
      };
    };
  };
}
