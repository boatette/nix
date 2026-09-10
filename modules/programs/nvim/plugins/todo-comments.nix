{ inputs, ... }:
{
  flake.modules.nvf.nvim =
    let
      inherit (inputs.self.lib.nvim) mod;
    in
    {
      vim = {
        notes.todo-comments.enable = true;

        keymaps = [
          (mod "n" "<leader>st" "snacks" "picker.todo_comments()" "Todo")
          (mod "n" "]t" "todo-comments" "jump_next()" "Next todo")
          (mod "n" "[t" "todo-comments" "jump_prev()" "Prev todo")
        ];
      };
    };
}
