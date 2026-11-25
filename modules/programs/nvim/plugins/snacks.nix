{ inputs, ... }:
{
  flake.modules.nvf.nvim =
    { lib, ... }:
    let
      inherit (lib.generators) mkLuaInline;
      inherit (inputs.self.constants) flakeDir;
      inherit (inputs.self.lib.nvim) mod;

      snack =
        mode: key: expr:
        mod mode key "snacks" expr;

      toggle =
        key: expr: desc:
        snack "n" key "toggle.${expr}:toggle()" desc;
    in
    {
      vim = {
        utility.snacks-nvim = {
          enable = true;

          setupOpts = {
            bigfile.size = 1024 * 1024;
            quickfile = { };

            indent.animate.enabled = false;
            terminal.win.position = "bottom";

            lazygit = {
              configure = false;

              win = {
                style = "float";
                position = "float";
              };
            };

            notifier = {
              top_down = false;
              style = mkLuaInline ''
                function(buf, notif, ctx)
                    ctx.opts.border = "top"
                    ctx.opts.title = { { " " .. notif.icon .. (notif.title or ""), ctx.hl.title } }
                    ctx.opts.title_pos = "left"

                    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(notif.msg, "\n"))
                end
              '';
            };

            picker = {
              layout = "custom";

              sources.files = {
                hidden = true;
                follow = true;
              };

              layouts.custom.layout = {
                box = "vertical";
                backdrop = true;
                row = 1000;
                width = 0;
                height = 0.4;
                border = "top";
                title = " {title} {live} {flags}";
                title_pos = "left";

                "@1" = {
                  box = "horizontal";
                  "@1" = {
                    win = "list";
                    border = "none";
                  };
                  "@2" = {
                    win = "preview";
                    title = "{preview}";
                    width = 0.6;
                    border = "left";
                  };
                };
                "@2" = {
                  win = "input";
                  height = 1;
                };
              };
            };
          };
        };

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
          (snack "n" "<leader>sm" "picker.marks()" "Marks")
          (snack "n" "<leader>sj" "picker.jumps()" "Jump list")
          (snack "n" "<leader>s'" "picker.registers()" "Registers")
          (snack "n" "<leader>fs" "picker.lsp_symbols()" "LSP document symbols")
          (snack "n" "<leader>fS" "picker.lsp_workspace_symbols()" "LSP workspace symbols")

          (snack "n" "gd" "picker.lsp_definitions()" "Go to definition")
          (snack "n" "gI" "picker.lsp_implementations()" "Go to implementations")
          (snack "n" "gy" "picker.lsp_type_definitions()" "Go to type definition")
          (snack "n" "grr" "picker.lsp_references()" "References")

          (snack "n" "<leader>xx" "picker.diagnostics()" "Workspace diagnostics")
          (snack "n" "<leader>xX" "picker.diagnostics_buffer()" "Buffer diagnostics")
          (snack "n" "<leader>xq" "picker.qflist()" "Quickfix list")
          (snack "n" "<leader>xl" "picker.loclist()" "Location list")
          (snack "n" "<leader>xi" "picker.lsp_incoming_calls()" "Incoming calls")
          (snack "n" "<leader>xo" "picker.lsp_outgoing_calls()" "Outgoing calls")

          (snack "n" "<leader>gc" "picker.git_log()" "Git log")
          (snack "n" "<leader>gF" "picker.git_status()" "Git status")
          (snack "n" "<leader>go" "gitbrowse()" "Git browse (open in browser)")
          (snack "n" "<leader>gg" "lazygit()" "Lazygit")
          (snack "n" "<leader>gl" "lazygit.log()" "Lazygit log")

          (snack [ "n" "t" ] "<C-`>" "terminal()" "Toggle terminal")
          (snack "n" "<leader>ot" "terminal()" "Toggle terminal")
          (snack "n" "<leader>ou" "picker.undo()" "Undo history")

          (snack "n" "<leader>un" "notifier.hide()" "Dismiss notifications")
          (snack "n" "<leader>uN" "picker.notifications()" "Browse notifications")

          (toggle "<leader>uz" "zen()" "Toggle zen mode")
          (toggle "<leader>uZ" "zoom()" "Toggle zoom")
          (toggle "<leader>uD" "dim()" "Toggle dimming")

          (toggle "<leader>ud" "diagnostics()" "Toggle diagnostics")
          (toggle "<leader>ug" "indent()" "Toggle indent guides")
          (toggle "<leader>ul" "line_number()" "Toggle line numbers")
          (toggle "<leader>uL" ''option("relativenumber", { name = "Relative numbers" })''
            "Toggle relative numbers"
          )
          (toggle "<leader>us" ''option("spell", { name = "Spelling" })'' "Toggle spelling")
          (toggle "<leader>uT" "treesitter()" "Toggle treesitter highlight")
          (toggle "<leader>uw" ''option("wrap", { name = "Wrap" })'' "Toggle wrap")
          (toggle "<leader>uW" ''option("list", { name = "Whitespace" })'' "Toggle whitespace")
          (toggle "<leader>u|" ''option("colorcolumn", { off = "", on = "120", name = "Colour column" })''
            "Toggle colour column"
          )

          (toggle "<leader>uA" ''option("showtabline", { off = 0, on = 2, name = "Tabline" })''
            "Toggle tabline"
          )
          (toggle "<leader>uC"
            ''option("conceallevel", { off = 0, on = math.max(vim.o.conceallevel, 2), name = "Conceal" })''
            "Toggle conceal"
          )
          (toggle "<leader>uS" ''option("laststatus", { off = 0, on = 3, name = "Statusline" })''
            "Toggle statusline"
          )

          (snack "n" "<leader>bd" "bufdelete()" "Delete buffer")
          (snack "n" "<leader>bD" "bufdelete({ force = true })" "Delete buffer (force)")
        ];
      };
    };
}
