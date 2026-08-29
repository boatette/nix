{ inputs, ... }:
{
  flake.modules.nixvim.nvim =
    { lib, ... }:
    let
      inherit (lib.nixvim) mkRaw;
      inherit (inputs.self.constants) flakeDir;

      disabledSnacks =
        lib.genAttrs
          [
            "animate"
            "dashboard"
            "debug"
            "dim"
            "explorer"
            "gh"
            "git"
            "gitbrowse"
            "health"
            "image"
            "input"
            "keymap"
            "profiler"
            "rename"
            "scope"
            "scratch"
            "scroll"
            "statuscolumn"
            "toggle"
            "util"
            "win"
            "words"
            "zen"
          ]
          (_: {
            enabled = false;
          });

      snack = mode: key: expr: desc: {
        inherit mode key;
        action = mkRaw ''
          function()
              require("snacks").${expr}
          end
        '';
        options.desc = desc;
      };
    in
    {
      plugins.snacks = {
        enable = true;

        settings = {
          bigfile = { };
          bufdelete = { };
          quickfile = { };

          indent.animate.enabled = false;
          terminal.win.position = "bottom";

          lazygit.win = {
            style = "float";
            position = "float";
          };

          notifier = {
            top_down = false;
            style = mkRaw ''
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

            layouts = mkRaw ''
              {
                  custom = {
                      layout = {
                          box = "vertical",
                          backdrop = true,
                          row = 1000,
                          width = 0,
                          height = 0.4,
                          border = "top",
                          title = " {title} {live} {flags}",
                          title_pos = "left",
                          {
                              box = "horizontal",
                              { win = "list", border = "none" },
                              { win = "preview", title = "{preview}", width = 0.6, border = "left" },
                          },
                          { win = "input", height = 1 },
                      },
                  },
              }
            '';
          };
        }
        // disabledSnacks;
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
      ];
    };
}
