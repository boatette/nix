{ inputs, ... }:
{
  flake.modules.nvf.nvim =
    { lib, ... }:
    let
      inherit (lib.generators) mkLuaInline;
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
          (inputs.self.lib.nvim.lua "n" "<leader>uh" /* lua */ ''
            function()
                local buf = vim.api.nvim_get_current_buf()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
            end
          '' "Toggle inlay hints")
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
