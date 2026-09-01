{ inputs, ... }:
{
  flake-file.inputs = {
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plugins-everforest-nvim = {
      url = "github:neanias/everforest-nvim";
      flake = false;
    };

    plugins-github-monochrome-nvim = {
      url = "github:idr4n/github-monochrome.nvim";
      flake = false;
    };
  };

  flake.modules = {
    nixvim = {
      core = {
        wrapRc = true;
        impureRtp = false;
        enableMan = false;
        performance.byteCompileLua.enable = true;

        extraConfigLuaPre = ''
          vim.loader.enable()
          pcall(function()
              require("vim._core.ui2").enable()
          end)
        '';
      };

      nvim.imports = [ inputs.self.modules.nixvim.core ];
    };

    homeManager.nvim =
      { pkgs, ... }:
      {
        home = {
          packages = [
            pkgs.local.nvim
            pkgs.local.vi
          ];

          sessionVariables = {
            EDITOR = "nvim";
            SUDO_EDITOR = "nvim";
          };
        };
      };
  };

  perSystem =
    { system, pkgs, ... }:
    let
      mkNvim =
        module:
        inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule {
          inherit pkgs module;
        };

      minimal = mkNvim inputs.self.modules.nixvim.core;
    in
    {
      packages = {
        nvim = mkNvim inputs.self.modules.nixvim.nvim;
        nvim-minimal = minimal;

        vi = pkgs.runCommandLocal "vi" { } ''
          mkdir -p $out/bin
          ln -s ${minimal}/bin/nvim $out/bin/vi
        '';
      };
    };
}
