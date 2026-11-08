{
  flake.modules.nvf.nvim =
    { pkgs, ... }:
    {
      vim.lazy.plugins."flutter-tools.nvim" = {
        package = pkgs.vimPlugins.flutter-tools-nvim;
        setupModule = "flutter-tools";

        setupOpts = {
          ui.notification_style = "native";
          widget_guides.enabled = true;
          lsp.color.enabled = true;
        };

        ft = "dart";
      };
    };

  # needs nvim-dap, which only nvim-full has
  flake.modules.nvf.nvim-full.vim.lazy.plugins."flutter-tools.nvim".setupOpts.debugger.enabled = true;
}
