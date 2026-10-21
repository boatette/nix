{
  flake.modules.nvf.nvim =
    { pkgs, ... }:
    {
      vim.lazy.plugins.rose-pine = {
        package = pkgs.vimPlugins.rose-pine;
        setupModule = "rose-pine";

        lazy = false;
        priority = 1000;

        after = ''vim.cmd.colorscheme("rose-pine-main")'';
      };
    };
}
