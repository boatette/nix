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

    nixos.nvim.environment.sessionVariables = {
      EDITOR = "nvim";
      SUDO_EDITOR = "nvim";
    };

    homeManager.nvim =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.local.nvim ];
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
