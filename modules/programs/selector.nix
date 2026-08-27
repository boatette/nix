{ inputs, ... }:
{
  flake-file.inputs.selector = {
    url = "github:boatette/selector";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.selector = {
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
