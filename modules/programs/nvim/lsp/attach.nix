{
  flake.modules.nvf.nvim =
    { lib, ... }:
    let
      inherit (lib.generators) mkLuaInline;

      trouble = key: panel: desc: {
        mode = "n";
        inherit key;
        action = "<cmd>Trouble ${panel}<cr>";
        desc = "${desc} (Trouble)";
        silent = false;
      };
    in
    {
      vim = {
        lsp = {
          inlayHints.enable = true;

          mappings = {
            goToDeclaration = "gD";
            hover = "K";
          };
        };

        keymaps = [
          (trouble "gd" "lsp_definitions toggle" "Go to definition")
          (trouble "gI" "lsp_implementations toggle" "Go to implementations")
          (trouble "gy" "lsp_type_definitions toggle" "Go to type definition")

          {
            mode = "n";
            key = "<leader>uh";
            action = ''
              function()
                  local buf = vim.api.nvim_get_current_buf()
                  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
              end
            '';
            lua = true;
            desc = "Toggle inlay hints";
            silent = false;
          }
        ];

        augroups = [ { name = "nvim_lsp_attach"; } ];

        autocmds = [
          {
            event = [ "LspAttach" ];
            group = "nvim_lsp_attach";
            desc = "LSP on-attach configuration";
            callback = mkLuaInline ''require("config.attach").on_attach'';
          }
        ];
      };
    };
}
