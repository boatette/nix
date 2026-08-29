{
  flake.modules.nixvim.nvim =
    let
      trouble = key: panel: desc: {
        mode = "n";
        inherit key;
        action = "<cmd>Trouble ${panel}<cr>";
        options.desc = "${desc} (Trouble)";
      };
    in
    {
      plugins.trouble.enable = true;

      keymaps = [
        (trouble "<leader>xx" "diagnostics toggle" "Workspace diagnostics")
        (trouble "<leader>xX" "diagnostics toggle filter.buf=0" "Document diagnostics")
        (trouble "<leader>xq" "qflist toggle" "Quickfix list")
        (trouble "<leader>xl" "loclist toggle" "Location list")
        (trouble "<leader>xs" "symbols toggle focus=false" "Symbols panel")
        (trouble "<leader>xi" "lsp_incoming_calls toggle" "Incoming calls")
        (trouble "<leader>xo" "lsp_outgoing_calls toggle" "Outgoing calls")
      ];
    };
}
