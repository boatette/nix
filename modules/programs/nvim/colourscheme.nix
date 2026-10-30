{
  flake.modules.nvf.nvim =
    { pkgs, ... }:
    {
      vim.lazy.plugins.rose-pine = {
        package = pkgs.vimPlugins.rose-pine;
        setupModule = "rose-pine";
        setupOpts.styles.transparency = true;

        lazy = false;
        priority = 1000;

        after = ''vim.cmd.colorscheme("rose-pine-main")'';
      };
    };
}
