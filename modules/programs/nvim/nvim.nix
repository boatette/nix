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
    nixvim.nvim = {
      wrapRc = true;
      performance.byteCompileLua.enable = true;

      extraConfigLua = ''
        vim.loader.enable()
        pcall(function()
            require("vim._core.ui2").enable()
        end)
      '';
    };

    nixos.nvim.environment.sessionVariables = {
      EDITOR = "nvim";
      SUDO_EDITOR = "nvim";
    };

    homeManager.nvim =
      { pkgs, ... }:
      {
        imports = [ inputs.nixvim.homeModules.nixvim ];

        xdg.configFile."nvim/.keep".text = "";

        programs.nixvim = {
          enable = true;
          imports = [ inputs.self.modules.nixvim.nvim ];
          nixpkgs.pkgs = pkgs;
        };
      };

  };

  perSystem =
    { system, pkgs, ... }:
    {
      packages.nvim = inputs.nixvim.legacyPackages.${system}.makeNixvimWithModule {
        inherit pkgs;
        module = inputs.self.modules.nixvim.nvim;
      };
    };
}
