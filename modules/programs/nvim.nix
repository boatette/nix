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

            luaConfigRC.core-pre = lib.nvim.dag.entryBefore [ "basic" ] ''
              pcall(function()
                  require("vim._core.ui2").enable()
              end)
            '';
          };
        };

      nvim = {
        imports = [ inputs.self.modules.nvf.core ];

        vim.viAlias = false;

        mnw.appName = "nvim";
      };

      nvim-full.imports = [ inputs.self.modules.nvf.nvim ];

      minimal = {
        imports = [ inputs.self.modules.nvf.core ];

        vim = {
          viAlias = false;
          vimAlias = false;
        };

        mnw.appName = "nvim";
      };
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

      minimal = mkNvf inputs.self.modules.nvf.minimal;
    in
    {
      packages = {
        nvim = mkNvf inputs.self.modules.nvf.nvim;
        nvim-full = mkNvf inputs.self.modules.nvf.nvim-full;
        nvim-minimal = minimal;

        vi = pkgs.runCommandLocal "vi" { } ''
          mkdir -p $out/bin
          ln -s ${minimal}/bin/nvim $out/bin/vi
        '';
      };
    };
}
