{ inputs, ... }:
{
  flake-file.inputs.nix-index-database = {
    url = "github:nix-community/nix-index-database";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules = {
    nixos.aspire.programs.command-not-found.enable = false;

    homeManager.boatette = {
      imports = [ inputs.nix-index-database.homeModules.nix-index ];

      programs = {
        nix-index.enable = true;

        nix-index-database.comma.enable = true;
      };
    };
  };
}
