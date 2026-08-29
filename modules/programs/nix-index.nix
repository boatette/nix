{ inputs, ... }:
{
  flake-file.inputs.nix-index-database = {
    url = "github:nix-community/nix-index-database";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules = {
    nixos.nix-index.programs.command-not-found.enable = false;

    homeManager.nix-index = {
      imports = [ inputs.nix-index-database.homeModules.nix-index ];

      programs = {
        nix-index = {
          enable = true;
          enableZshIntegration = true;
        };

        nix-index-database.comma.enable = true;
      };
    };
  };
}
