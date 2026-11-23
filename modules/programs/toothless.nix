{ inputs, ... }:
{
  flake-file.inputs.toothless = {
    url = "github:boatette/toothless";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.boatette = {
    imports = [ inputs.toothless.homeModules.default ];

    programs.toothless = {
      enable = true;

      settings = {
        corner = "bottom-left";
        margin_y = 0;
      };
    };
  };
}
