{
  flake.modules.nvf.nvim =
    { pkgs, ... }:
    {
      vim.lazy.plugins."flutter-tools.nvim" = {
        package = pkgs.vimPlugins.flutter-tools-nvim;
        setupModule = "flutter-tools";

        setupOpts = {
          ui.notification_style = "native";
          debugger.enabled = true;
          widget_guides.enabled = true;
          lsp.color.enabled = true;
        };

        ft = "dart";
      };
    };
}
