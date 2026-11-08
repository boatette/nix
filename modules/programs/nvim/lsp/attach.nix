{ inputs, ... }:
{
  flake.modules.nvf.nvim =
    { lib, ... }:
    let
      inherit (lib.generators) mkLuaInline;
      inherit (inputs.self.lib.nvim) lua;

      codeAction =
        key: kind: desc:
        lua "n" key /* lua */ ''
          function()
              vim.lsp.buf.code_action({
                  context = { only = { "${kind}" }, diagnostics = {} },
                  apply = true,
              })
          end
        '' desc;
    in
    {
      vim = {
        lsp.mappings = {
          goToDeclaration = "gD";
          hover = "K";
        };

        keymaps = [
          (lua "n" "<leader>ca" "vim.lsp.buf.code_action" "Code action")
          (lua "n" "<leader>cr" "vim.lsp.buf.rename" "Rename symbol")
          (codeAction "<leader>co" "source.organizeImports" "Organise imports")
          (codeAction "<leader>cq" "quickfix" "Quick fix")
          (lua "n" "<leader>cl" "vim.lsp.codelens.run" "Run code lens")
          (lua "n" "<leader>cd" "vim.diagnostic.open_float" "Line diagnostics")

          (lua "n" "<leader>uh" /* lua */ ''
            function()
                local buf = vim.api.nvim_get_current_buf()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
            end
          '' "Toggle inlay hints")
        ];

        augroups = [ { name = "LspAttachConfig"; } ];

        autocmds = [
          {
            event = [ "LspAttach" ];
            group = "LspAttachConfig";
            desc = "LSP on-attach configuration";
            callback = mkLuaInline ''require("config.attach").on_attach'';
          }
          {
            event = [ "LspDetach" ];
            group = "LspAttachConfig";
            desc = "LSP on-detach cleanup";
            callback = mkLuaInline ''require("config.attach").on_detach'';
          }
        ];
      };
    };
}
