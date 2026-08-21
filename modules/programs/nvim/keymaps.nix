{ inputs, ... }:
{
  flake.modules.nixvim.nvim =
    { lib, ... }:
    let
      inherit (lib.nixvim) mkRaw;
      inherit (inputs.self.constants) flakeDir;

      bind = mode: key: action: desc: {
        inherit mode key action;
        options.desc = desc;
      };

      rebuild =
        mode: sudo:
        mkRaw ''
          function()
              require("snacks").terminal(
                  "${lib.optionalString sudo "run0 "}nixos-rebuild ${mode} --flake ${flakeDir}",
                  { interactive = true }
              )
          end
        '';
    in
    {
      keymaps = [
        (bind "n" "<leader>ns" (rebuild "switch" true) "Rebuild switch")
        (bind "n" "<leader>nt" (rebuild "test" true) "Rebuild test")
        (bind "n" "<leader>nb" (rebuild "boot" true) "Rebuild boot")
        (bind "n" "<leader>nd" (rebuild "dry-build" false) "Rebuild dry-build")

        (bind "n" "<Esc>" "<cmd>nohlsearch<cr>" "Clear search highlight")
        (bind "n" "<leader>v" "ggVG" "Select whole buffer")
        (bind "v" "p" "\"_dP`[v`]=" "Paste without yank")
        (bind "n" "J" "mzJ`z" "Better join")

        (bind "n" "<leader>R" (mkRaw ''
          function()
              local session = vim.fn.stdpath("state") .. "/restart_session.vim"
              vim.cmd("mksession! " .. vim.fn.fnameescape(session))
              vim.cmd("restart source " .. vim.fn.fnameescape(session))
          end
        '') "Restart Neovim")

        {
          mode = "n";
          key = "i";
          action = mkRaw ''
            function()
                return vim.fn.getline("."):len() == 0 and '"_cc' or "i"
            end
          '';
          options = {
            expr = true;
            desc = "Auto-indent on empty line";
          };
        }

        (bind "n" "j" "gj" "Navigate wrapped lines")
        (bind "n" "k" "gk" "Navigate wrapped lines")

        (bind "v" "<" "<gv" "Indent left")
        (bind "v" ">" ">gv" "Indent right")

        {
          mode = "v";
          key = "J";
          action = ":m '>+1<cr>gv=gv";
          options = {
            silent = true;
            desc = "Move lines down";
          };
        }
        {
          mode = "v";
          key = "K";
          action = ":m '<-2<cr>gv=gv";
          options = {
            silent = true;
            desc = "Move lines up";
          };
        }

        (bind "n" "<C-d>" "<C-d>zz" "Half page down (centred)")
        (bind "n" "<C-u>" "<C-u>zz" "Half page up (centred)")
        (bind "n" "n" "nzzzv" "Next search result (centred)")
        (bind "n" "N" "Nzzzv" "Prev search result (centred)")

        (bind "n" "<C-h>" "<C-w>h" "Focus left window")
        (bind "n" "<C-j>" "<C-w>j" "Focus lower window")
        (bind "n" "<C-k>" "<C-w>k" "Focus upper window")
        (bind "n" "<C-l>" "<C-w>l" "Focus right window")

        (bind "n" "<C-Up>" "<cmd>resize +2<cr>" "Increase height")
        (bind "n" "<C-Down>" "<cmd>resize -2<cr>" "Decrease height")
        (bind "n" "<C-Left>" "<cmd>vertical resize -2<cr>" "Decrease width")
        (bind "n" "<C-Right>" "<cmd>vertical resize +2<cr>" "Increase width")

        (bind "n" "<leader>wd" "<C-W>c" "Delete window")
        (bind "n" "<leader>w-" "<C-W>s" "Split below")
        (bind "n" "<leader>w|" "<C-W>v" "Split right")
        (bind "n" "<leader>w=" "<C-w>=" "Equalise windows")

        (bind "n" "<leader>fn" "<cmd>enew<cr>" "New file")

        (bind "n" "<leader>ca" (mkRaw "vim.lsp.buf.code_action") "Code action")
        (bind "n" "<leader>cr" (mkRaw "vim.lsp.buf.rename") "Rename symbol")
        (bind "n" "<leader>co" (mkRaw ''
          function()
              vim.lsp.buf.code_action({
                  context = { only = { "source.organizeImports" }, diagnostics = {} },
                  apply = true,
              })
          end
        '') "Organise imports")
        (bind "n" "<leader>cq" (mkRaw ''
          function()
              vim.lsp.buf.code_action({
                  context = { only = { "quickfix" }, diagnostics = {} },
                  apply = true,
              })
          end
        '') "Quick fix")
        (bind "n" "<leader>cl" (mkRaw "vim.lsp.codelens.run") "Run code lens")
        (bind "i" "<C-k>" (mkRaw "vim.lsp.buf.signature_help") "Signature help")

        (bind "n" "<leader>cd" (mkRaw "vim.diagnostic.open_float") "Line diagnostics")
        (bind "n" "[d" (mkRaw ''
          function()
              vim.diagnostic.jump({ count = -1, float = true })
          end
        '') "Prev diagnostic")
        (bind "n" "]d" (mkRaw ''
          function()
              vim.diagnostic.jump({ count = 1, float = true })
          end
        '') "Next diagnostic")

        (bind "n" "[q" "<cmd>cprev<cr>" "Prev quickfix")
        (bind "n" "]q" "<cmd>cnext<cr>" "Next quickfix")

        (bind "t" "<Esc><Esc>" "<C-\\><C-n>" "Exit terminal mode")
      ];
    };
}
