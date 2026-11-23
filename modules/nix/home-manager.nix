{ config, inputs, ... }:
{
  flake-file.inputs.home-manager = {
    url = "github:nix-community/home-manager/${config.flake.constants.homeManagerBranch}";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.aspire = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "bak";
    };
  };
}
