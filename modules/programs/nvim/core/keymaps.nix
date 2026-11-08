{ inputs, ... }:
{
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
        (cmd "x" "p" "\"_dP`[v`]=" "Paste without yank")
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

        # by display line, unless given a count, which relativenumber counts in real lines
        ((cmd "n" "j" "v:count == 0 ? 'gj' : 'j'" "Navigate wrapped lines") // { expr = true; })
        ((cmd "n" "k" "v:count == 0 ? 'gk' : 'k'" "Navigate wrapped lines") // { expr = true; })

        (cmd "x" "<" "<gv" "Indent left")
        (cmd "x" ">" ">gv" "Indent right")

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

        (cmd "t" "<Esc><Esc>" "<C-\\><C-n>" "Exit terminal mode")
      ];
    };
}
