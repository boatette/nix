{
  flake.modules.nvf.nvim =
    {
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib.nvim.dag) entryAfter;
    in
    {
      vim = {
        startPlugins = with pkgs.vimPlugins; [
          catppuccin-nvim
          everforest
          kanagawa-nvim
          nord-nvim
          rose-pine
          tokyonight-nvim
          zenbones-nvim

          lush-nvim
          mini-base16
        ];

        luaConfigRC.colourscheme = entryAfter [ "autocmds" ] ''
          require("colourscheme").setup(require("colourscheme.providers"))
        '';
      };
    };
}
