{ inputs, ... }:

{
  flake.modules.homeManager.desktop = {
    imports = [ inputs.selector.homeModules.selector ];

    programs.selector = {
      enable = true;

      settings = {
        colors = "noctalia.toml";
      };
    };
  };
}
