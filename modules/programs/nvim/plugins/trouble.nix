{
  flake.modules.nvf.nvim =
    let
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
          (trouble "<leader>xs" "symbols toggle focus=false" "Symbols panel")
          (trouble "<leader>xi" "lsp_incoming_calls toggle" "Incoming calls")
          (trouble "<leader>xo" "lsp_outgoing_calls toggle" "Outgoing calls")
        ];
      };
    };
}
