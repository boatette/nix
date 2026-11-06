{ inputs, ... }:
{
  flake-file.inputs.toothless = {
    url = "git+file:///home/boatette/Projects/toothless";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.toothless = {
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
