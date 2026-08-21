{ inputs, ... }:
{
  flake.modules.nixvim.nvim =
    { lib, ... }:
    let
      inherit (lib.nixvim) mkRaw;
      inherit (inputs.self.constants) flakeDir;

      snack = mode: key: expr: desc: {
        inherit mode key;
        action = mkRaw ''
          function()
              require("snacks").${expr}
          end
        '';
        options.desc = desc;
      };

      trouble = key: panel: desc: {
        mode = "n";
        inherit key;
        action = "<cmd>Trouble ${panel}<cr>";
        options.desc = "${desc} (Trouble)";
      };
    in
    {
      keymaps = [
        (snack "n" "<leader><space>" "picker.smart()" "Smart find (files/recent)")
        (snack "n" "<leader>ff" "picker.files()" "Find files")
        (snack "n" "<leader>fr" "picker.recent()" "Recent files")
        (snack "n" "<leader>fR" "picker.recent({ filter = { cwd = true } })" "Recent files (cwd)")
        (snack "n" "<leader>sg" "picker.grep()" "Live grep")
        (snack [ "n" "x" ] "<leader>sw" "picker.grep_word()" "Grep word under cursor")
        (snack "n" "<leader>fb" "picker.buffers()" "Buffers")
        (snack "n" "<leader>sh" "picker.help()" "Help tags")
        (snack "n" "<leader>sk" "picker.keymaps()" "Keymaps")
        (snack "n" "<leader>fc"
          ''picker.files({ cwd = vim.fn.expand("${flakeDir}/modules/programs/nvim") })''
          "Config files"
        )
        (snack "n" "<leader>uc" "picker.colorschemes()" "Colorschemes")
        (snack "n" "<leader>sm" "picker.marks()" "Marks")
        (snack "n" "<leader>sj" "picker.jumps()" "Jump list")
        (snack "n" "<leader>s'" "picker.registers()" "Registers")
        (snack "n" "<leader>fs" "picker.lsp_symbols()" "LSP document symbols")
        (snack "n" "<leader>fS" "picker.lsp_workspace_symbols()" "LSP workspace symbols")

        (snack "n" "<leader>gc" "picker.git_log()" "Git log")
        (snack "n" "<leader>gF" "picker.git_status()" "Git status")
        (snack "n" "<leader>go" "gitbrowse()" "Git browse (open in browser)")
        (snack "n" "<leader>gg" "lazygit()" "Lazygit")
        (snack "n" "<leader>gl" "lazygit.log()" "Lazygit log")

        (snack [ "n" "t" ] "<C-`>" "terminal()" "Toggle terminal")
        (snack "n" "<leader>ot" "terminal()" "Toggle terminal")

        (snack "n" "<leader>un" "notifier.hide()" "Dismiss notifications")
        (snack "n" "<leader>uN" "picker.notifications()" "Browse notifications")

        (snack "n" "<leader>bd" "bufdelete()" "Delete buffer")
        (snack "n" "<leader>bD" "bufdelete({ force = true })" "Delete buffer (force)")

        (snack "n" "<leader>st" "picker.todo_comments()" "Todo")
        {
          mode = "n";
          key = "]t";
          action = mkRaw ''function() require("todo-comments").jump_next() end'';
          options.desc = "Next todo";
        }
        {
          mode = "n";
          key = "[t";
          action = mkRaw ''function() require("todo-comments").jump_prev() end'';
          options.desc = "Prev todo";
        }

        {
          mode = "n";
          key = "<S-h>";
          action = "<cmd>BufferLineCyclePrev<CR>";
          options.desc = "Prev tab";
        }
        {
          mode = "n";
          key = "<S-l>";
          action = "<cmd>BufferLineCycleNext<CR>";
          options.desc = "Next tab";
        }

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
