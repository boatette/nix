{ inputs, ... }:
{
  flake-file.inputs = {
    nvf = {
      url = "github:notashelf/nvf";
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
    nvf = {
      core =
        { lib, ... }:
        {
          vim = {
            vendoredKeymaps.enable = false;

            enableLuaLoader = true;

            lazy.enable = false;

            luaConfigRC.core-pre = lib.nvim.dag.entryBefore [ "basic" ] ''
              pcall(function()
                  require("vim._core.ui2").enable()
              end)
            '';
          };

          mnw.appName = "nvim";
        };

      nvim.imports = [ inputs.self.modules.nvf.core ];
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
    { pkgs, ... }:
    let
      mkNvf =
        module:
        (inputs.nvf.lib.neovimConfiguration {
          inherit pkgs;
          modules = [ module ];
        }).neovim;

      minimal = mkNvf inputs.self.modules.nvf.core;
    in
    {
      packages = {
        nvim = mkNvf inputs.self.modules.nvf.nvim;
        nvim-minimal = minimal;

        vi = pkgs.runCommandLocal "vi" { } ''
          mkdir -p $out/bin
          ln -s ${minimal}/bin/nvim $out/bin/vi
        '';
      };
    };
}
