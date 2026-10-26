{ inputs, ... }:
{
  flake.modules.nvf.nvim =
    let
      inherit (inputs.self.constants) flakeDir;
      inherit (inputs.self.lib.nvim) mod;

      rebuild = inputs.self.lib.rebuild flakeDir;

      nixosRebuild =
        key: cmd: desc:
        mod "n" key "snacks" ''terminal("${cmd}", { interactive = true })'' desc;
    in
    {
      vim.keymaps = [
        (nixosRebuild "<leader>ns" (rebuild.os "switch") "Rebuild switch")
        (nixosRebuild "<leader>nt" (rebuild.os "test") "Rebuild test")
        (nixosRebuild "<leader>nb" (rebuild.os "boot") "Rebuild boot")
        (nixosRebuild "<leader>nd" rebuild.dryBuild "Rebuild dry-build")
      ];
    };

  flake.modules.nvf.core =
    let
      inherit (inputs.self.lib.nvim) cmd lua;

      # moves the split on the arrow's side of the window that way, or the opposite one at the screen edge
      moveSplit =
        key: dir: desc:
        let
          vertical = dir == "h" || dir == "l";
          # a separator/statusline belongs to the window left of/above it
          back = if vertical then "h" else "k";
          fwd = if vertical then "l" else "j";
          sign = if dir == back then "-" else "";
        in
        lua "n" key /* lua */ ''
          function()
              local cur = vim.fn.winnr()
              local prev, next = vim.fn.winnr("${back}"), vim.fn.winnr("${fwd}")
              local owner
              if ${if dir == back then "prev ~= cur" else "next == cur"} then
                  owner = prev
              else
                  owner = cur
              end
              if owner == cur and next == cur then
                  return
              end
              vim.fn.${
                if vertical then "win_move_separator" else "win_move_statusline"
              }(owner, ${sign}2 * vim.v.count1)
          end
        '' desc;
    in
    {
      vim.keymaps = [
        (cmd "n" "<Esc>" "<cmd>nohlsearch<cr>" "Clear search highlight")
        (cmd "n" "<leader>v" "ggVG" "Select whole buffer")
        (cmd "v" "p" "\"_dP`[v`]=" "Paste without yank")
        (cmd "n" "J" "mzJ`z" "Better join")

        (
          lua "n" "i" /* lua */ ''
            function()
                return vim.fn.getline("."):len() == 0 and '"_cc' or "i"
            end
          '' "Auto-indent on empty line"
          // {
            expr = true;
          }
        )

        (cmd "n" "j" "gj" "Navigate wrapped lines")
        (cmd "n" "k" "gk" "Navigate wrapped lines")

        (cmd "v" "<" "<gv" "Indent left")
        (cmd "v" ">" ">gv" "Indent right")

        (cmd "n" "<C-d>" "<C-d>zz" "Half page down (centred)")
        (cmd "n" "<C-u>" "<C-u>zz" "Half page up (centred)")
        (cmd "n" "n" "nzzzv" "Next search result (centred)")
        (cmd "n" "N" "Nzzzv" "Prev search result (centred)")

        (cmd "n" "<C-h>" "<C-w>h" "Focus left window")
        (cmd "n" "<C-j>" "<C-w>j" "Focus lower window")
        (cmd "n" "<C-k>" "<C-w>k" "Focus upper window")
        (cmd "n" "<C-l>" "<C-w>l" "Focus right window")

        (moveSplit "<C-Up>" "k" "Move split up")
        (moveSplit "<C-Down>" "j" "Move split down")
        (moveSplit "<C-Left>" "h" "Move split left")
        (moveSplit "<C-Right>" "l" "Move split right")

        (cmd "n" "<leader>wd" "<C-W>c" "Delete window")
        (cmd "n" "<leader>w-" "<C-W>s" "Split below")
        (cmd "n" "<leader>w|" "<C-W>v" "Split right")
        (cmd "n" "<leader>w=" "<C-w>=" "Equalise windows")

        (cmd "n" "<leader>fn" "<cmd>enew<cr>" "New file")

        (lua "n" "<leader>ca" "vim.lsp.buf.code_action" "Code action")
        (lua "n" "<leader>cr" "vim.lsp.buf.rename" "Rename symbol")
        (lua "n" "<leader>co" /* lua */ ''
          function()
              vim.lsp.buf.code_action({
                  context = { only = { "source.organizeImports" }, diagnostics = {} },
                  apply = true,
              })
          end
        '' "Organise imports")
        (lua "n" "<leader>cq" /* lua */ ''
          function()
              vim.lsp.buf.code_action({
                  context = { only = { "quickfix" }, diagnostics = {} },
                  apply = true,
              })
          end
        '' "Quick fix")
        (lua "n" "<leader>cl" "vim.lsp.codelens.run" "Run code lens")
        (lua "i" "<C-k>" "vim.lsp.buf.signature_help" "Signature help")

        (lua "n" "<leader>cd" "vim.diagnostic.open_float" "Line diagnostics")
        (lua "n" "[d" /* lua */ ''
          function()
              vim.diagnostic.jump({ count = -1, float = true })
          end
        '' "Prev diagnostic")
        (lua "n" "]d" /* lua */ ''
          function()
              vim.diagnostic.jump({ count = 1, float = true })
          end
        '' "Next diagnostic")

        (cmd "n" "[q" "<cmd>cprev<cr>" "Prev quickfix")
        (cmd "n" "]q" "<cmd>cnext<cr>" "Next quickfix")

        (cmd "t" "<Esc><Esc>" "<C-\\><C-n>" "Exit terminal mode")
      ];
    };
}
