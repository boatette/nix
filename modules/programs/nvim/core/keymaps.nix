{ inputs, ... }:
{
  flake.modules.nvf.nvim =
    let
      inherit (inputs.self.constants) flakeDir;

      luaBind = key: action: desc: {
        mode = "n";
        inherit key action desc;
        lua = true;
        silent = false;
      };

      term = cmd: ''
        function()
            require("snacks").terminal("${cmd}", { interactive = true })
        end
      '';

      rebuild = inputs.self.lib.rebuild flakeDir;
    in
    {
      vim.keymaps = [
        (luaBind "<leader>ns" (term (rebuild.os "switch")) "Rebuild switch")
        (luaBind "<leader>nt" (term (rebuild.os "test")) "Rebuild test")
        (luaBind "<leader>nb" (term (rebuild.os "boot")) "Rebuild boot")
        (luaBind "<leader>nd" (term rebuild.dryBuild) "Rebuild dry-build")
      ];
    };

  flake.modules.nvf.core =
    let
      cmdBind = mode: key: action: desc: {
        inherit
          mode
          key
          action
          desc
          ;
        silent = false;
      };

      luaBind = mode: key: action: desc: {
        inherit
          mode
          key
          action
          desc
          ;
        lua = true;
        silent = false;
      };
    in
    {
      vim.keymaps = [
        (cmdBind "n" "<Esc>" "<cmd>nohlsearch<cr>" "Clear search highlight")
        (cmdBind "n" "<leader>v" "ggVG" "Select whole buffer")
        (cmdBind "v" "p" "\"_dP`[v`]=" "Paste without yank")
        (cmdBind "n" "J" "mzJ`z" "Better join")

        (luaBind "n" "<leader>R" ''
          function()
              local session = vim.fn.stdpath("state") .. "/restart_session.vim"
              vim.cmd("mksession! " .. vim.fn.fnameescape(session))
              vim.cmd("restart source " .. vim.fn.fnameescape(session))
          end
        '' "Restart Neovim")

        {
          mode = "n";
          key = "i";
          action = ''
            function()
                return vim.fn.getline("."):len() == 0 and '"_cc' or "i"
            end
          '';
          lua = true;
          silent = false;
          expr = true;
          desc = "Auto-indent on empty line";
        }

        (cmdBind "n" "j" "gj" "Navigate wrapped lines")
        (cmdBind "n" "k" "gk" "Navigate wrapped lines")

        (cmdBind "v" "<" "<gv" "Indent left")
        (cmdBind "v" ">" ">gv" "Indent right")

        {
          mode = "v";
          key = "J";
          action = ":m '>+1<cr>gv=gv";
          silent = true;
          desc = "Move lines down";
        }
        {
          mode = "v";
          key = "K";
          action = ":m '<-2<cr>gv=gv";
          silent = true;
          desc = "Move lines up";
        }

        (cmdBind "n" "<C-d>" "<C-d>zz" "Half page down (centred)")
        (cmdBind "n" "<C-u>" "<C-u>zz" "Half page up (centred)")
        (cmdBind "n" "n" "nzzzv" "Next search result (centred)")
        (cmdBind "n" "N" "Nzzzv" "Prev search result (centred)")

        (cmdBind "n" "<C-h>" "<C-w>h" "Focus left window")
        (cmdBind "n" "<C-j>" "<C-w>j" "Focus lower window")
        (cmdBind "n" "<C-k>" "<C-w>k" "Focus upper window")
        (cmdBind "n" "<C-l>" "<C-w>l" "Focus right window")

        (cmdBind "n" "<C-Up>" "<cmd>resize +2<cr>" "Increase height")
        (cmdBind "n" "<C-Down>" "<cmd>resize -2<cr>" "Decrease height")
        (cmdBind "n" "<C-Left>" "<cmd>vertical resize -2<cr>" "Decrease width")
        (cmdBind "n" "<C-Right>" "<cmd>vertical resize +2<cr>" "Increase width")

        (cmdBind "n" "<leader>wd" "<C-W>c" "Delete window")
        (cmdBind "n" "<leader>w-" "<C-W>s" "Split below")
        (cmdBind "n" "<leader>w|" "<C-W>v" "Split right")
        (cmdBind "n" "<leader>w=" "<C-w>=" "Equalise windows")

        (cmdBind "n" "<leader>fn" "<cmd>enew<cr>" "New file")

        (luaBind "n" "<leader>ca" "vim.lsp.buf.code_action" "Code action")
        (luaBind "n" "<leader>cr" "vim.lsp.buf.rename" "Rename symbol")
        (luaBind "n" "<leader>co" ''
          function()
              vim.lsp.buf.code_action({
                  context = { only = { "source.organizeImports" }, diagnostics = {} },
                  apply = true,
              })
          end
        '' "Organise imports")
        (luaBind "n" "<leader>cq" ''
          function()
              vim.lsp.buf.code_action({
                  context = { only = { "quickfix" }, diagnostics = {} },
                  apply = true,
              })
          end
        '' "Quick fix")
        (luaBind "n" "<leader>cl" "vim.lsp.codelens.run" "Run code lens")
        (luaBind "i" "<C-k>" "vim.lsp.buf.signature_help" "Signature help")

        (luaBind "n" "<leader>cd" "vim.diagnostic.open_float" "Line diagnostics")
        (luaBind "n" "[d" ''
          function()
              vim.diagnostic.jump({ count = -1, float = true })
          end
        '' "Prev diagnostic")
        (luaBind "n" "]d" ''
          function()
              vim.diagnostic.jump({ count = 1, float = true })
          end
        '' "Next diagnostic")

        (cmdBind "n" "[q" "<cmd>cprev<cr>" "Prev quickfix")
        (cmdBind "n" "]q" "<cmd>cnext<cr>" "Next quickfix")

        (cmdBind "t" "<Esc><Esc>" "<C-\\><C-n>" "Exit terminal mode")
      ];
    };
}
