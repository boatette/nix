{ inputs, ... }:
{
  flake.modules.nvf.nvim =
    let
      trouble =
        key: panel: desc:
        inputs.self.lib.nvim.cmd "n" key "<cmd>Trouble ${panel}<cr>" "${desc} (Trouble)";
    in
    {
      vim = {
        lsp.trouble = {
          enable = true;

          mappings = {
            workspaceDiagnostics = "<leader>xx";
            documentDiagnostics = "<leader>xX";
            quickfix = "<leader>xq";
            locList = "<leader>xl";
            lspReferences = "gr";
          };
        };

        keymaps = [
          (trouble "gd" "lsp_definitions toggle" "Go to definition")
          (trouble "gI" "lsp_implementations toggle" "Go to implementations")
          (trouble "gy" "lsp_type_definitions toggle" "Go to type definition")

          (trouble "<leader>xs" "symbols toggle focus=false" "Symbols panel")
          (trouble "<leader>xi" "lsp_incoming_calls toggle" "Incoming calls")
          (trouble "<leader>xo" "lsp_outgoing_calls toggle" "Outgoing calls")
        ];
      };
    };
}
