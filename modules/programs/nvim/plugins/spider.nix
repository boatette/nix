{ inputs, ... }:
{
  flake.modules.nvf.core =
    { pkgs, ... }:
    let
      spider =
        motion:
        inputs.self.lib.nvim.mod [
          "n"
          "o"
          "x"
        ] motion "spider" ''motion("${motion}")'' "Spider-${motion}";
    in
    {
      vim.lazy.plugins.nvim-spider = {
        package = pkgs.vimPlugins.nvim-spider;
        setupModule = "spider";
        setupOpts = { };

        keys = map spider [
          "w"
          "e"
          "b"
          "ge"
        ];
      };
    };
}
