{
  flake.modules.nvf.nvim =
    { lib, pkgs, ... }:
    let
      inherit (lib.generators) mkLuaInline;
    in
    {
      vim = {
        # on PATH rather than as server.cmd, which nvim appends to, so a project's own toolchain comes first
        extraPackages = [ pkgs.rust-analyzer ];

        languages.rust = {
          enable = true;
          lsp.enable = false;

          # rustaceanvim runs the adapter itself, so dap.enable stays off; this picks lldb-dap over codelldb
          dap.debugger = [ "lldb" ];

          extensions = {
            crates-nvim.enable = true;

            rustaceanvim = {
              enable = true;

              setupOpts = {
                tools.hover_actions.replace_builtin_hover = true;

                server = {
                  default_settings."rust-analyzer" = {
                    cargo.features = "all";
                    check.command = "clippy";
                  };

                  on_attach = mkLuaInline /* lua */ ''
                    function(_, bufnr)
                        local function map(key, cmd, desc)
                            vim.keymap.set("n", key, "<cmd>RustLsp " .. cmd .. "<cr>", { buffer = bufnr, desc = desc })
                        end

                        map("<leader>rr", "runnables", "Runnables")
                        map("<leader>rd", "debuggables", "Debuggables")
                        map("<leader>rt", "testables", "Testables")
                        map("<leader>rm", "expandMacro", "Expand macro")
                        map("<leader>re", "explainError", "Explain error")
                        map("<leader>rD", "renderDiagnostic", "Render diagnostic")
                        map("<leader>rc", "openCargo", "Open Cargo.toml")
                        map("<leader>rp", "parentModule", "Parent module")
                    end
                  '';
                };
              };
            };
          };
        };
      };
    };
}
