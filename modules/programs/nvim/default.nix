{ inputs, ... }:

let
  mkNvim =
    {
      system,
      configDirectory,
    }:
    inputs.wrapper-modules.wrappers.neovim.wrap [
      {
        pkgs = import inputs.nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      }
      (import ./_module.nix { inherit inputs configDirectory; })
    ];
in
{
  flake.modules.nixos.base.environment.sessionVariables = {
    EDITOR = "nvim";
    SUDO_EDITOR = "nvim";
  };

  flake.modules.homeManager.base =
    { config, pkgs, ... }:
    {
      xdg.configFile."nvim/.keep".text = "";

      home.packages = [
        (mkNvim {
          inherit (pkgs.stdenv.hostPlatform) system;
          configDirectory = "${config.home.homeDirectory}/nix/modules/programs/nvim/config";
        })
      ];
    };

  perSystem =
    { system, ... }:
    {
      packages.nvim = mkNvim {
        inherit system;
        configDirectory = ./config;
      };
    };
}
