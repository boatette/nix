{ inputs, ... }:
{
  flake-file.inputs.nvf = {
    url = "github:notashelf/nvf";
    inputs = {
      flake-compat.follows = "";
      nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.nvf.nvim =
    { lib, ... }:
    {
      vim = {
        appname = "nvim";
        enableLuaLoader = true;
        vendoredKeymaps.enable = false;

        luaConfigRC.ui2 = lib.nvim.dag.entryBefore [ "basic" ] ''
          pcall(function()
              require("vim._core.ui2").enable()
          end)
        '';
      };
    };

  flake.modules.nixos.aspire =
    { pkgs, ... }:
    {
      environment = {
        systemPackages = [ pkgs.local.nvim ];
        variables.EDITOR = "nvim";
      };
    };

  perSystem =
    { pkgs, ... }:
    {
      packages.nvim =
        (inputs.nvf.lib.neovimConfiguration {
          inherit pkgs;
          modules = [ inputs.self.modules.nvf.nvim ];
        }).neovim;
    };
}
