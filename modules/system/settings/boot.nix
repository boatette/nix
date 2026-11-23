{ inputs, ... }:
{
  flake-file.inputs.lanzaboote = {
    url = "github:nix-community/lanzaboote/v1.1.0";
    inputs = {
      nixpkgs.follows = "nixpkgs";
      pre-commit.follows = "";
    };
  };

  flake.modules.nixos.aspire =
    { pkgs, ... }:
    {
      imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

      boot = {
        kernelPackages = pkgs.linuxPackages_latest;

        lanzaboote = {
          enable = true;
          autoEnrollKeys.enable = true;
          autoGenerateKeys.enable = true;
          configurationLimit = 5;
          pkiBundle = "/var/lib/sbctl";
        };

        loader = {
          efi.canTouchEfiVariables = true;
          timeout = 0;
        };

        tmp.cleanOnBoot = true;
      };

      environment.systemPackages = [ pkgs.sbctl ];
    };
}
