{
  flake.modules.nvf.nvim =
    { pkgs, ... }:
    {
      vim = {
        extraPackages = [ pkgs.rust-analyzer ];

        languages.rust = {
          enable = true;
          lsp.enable = false;
          dap.enable = false;

          extensions.rustaceanvim = {
            enable = true;

            setupOpts = {
              tools.hover_actions.replace_builtin_hover = true;

              server.default_settings."rust-analyzer" = {
                cargo.allFeatures = true;
                checkOnSave = true;
                check.command = "clippy";
                inlayHints.enable = true;
                procMacro.enable = true;
              };

              dap.adapter = {
                type = "executable";
                command = "lldb-dap";
                name = "lldb";
              };
            };
          };
        };
      };
    };
}
