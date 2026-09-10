{ inputs, ... }:
{
  flake.modules.nvf.nvim =
    {
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib.nvim.dag) entryAfter;

      mkFlakePlugin =
        name: src:
        pkgs.vimUtils.buildVimPlugin {
          inherit name src;
        };
    in
    {
      vim = {
        startPlugins =
          (with pkgs.vimPlugins; [
            catppuccin-nvim
            kanagawa-nvim
            nord-nvim
            rose-pine
            tokyonight-nvim

            mini-base16
          ])
          ++ [
            (mkFlakePlugin "everforest-nvim" inputs.plugins-everforest-nvim)
            (mkFlakePlugin "github-monochrome-nvim" inputs.plugins-github-monochrome-nvim)
          ];

        luaConfigRC.colourscheme = entryAfter [ "autocmds" ] ''
          require("colourscheme").setup(require("colourscheme.providers"))
        '';
      };
    };
}
