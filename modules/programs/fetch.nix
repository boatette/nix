{ inputs, ... }:
{
  flake-file.inputs.areofyl-fetch = {
    url = "github:areofyl/fetch";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.fetch = {
    imports = [ inputs.areofyl-fetch.homeManagerModules.default ];
    programs.fetch.enable = true;
  };
}
