{
  flake.modules.nixvim.nvim =
    { lib, ... }:
    let
      inherit (lib.nixvim) mkRaw;
    in
    {
      plugins.todo-comments.enable = true;

      keymaps = [
        {
          mode = "n";
          key = "<leader>st";
          action = mkRaw ''
            function()
                require("snacks").picker.todo_comments()
            end
          '';
          options.desc = "Todo";
        }
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
      ];
    };
}
