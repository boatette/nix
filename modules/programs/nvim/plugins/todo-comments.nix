{
  flake.modules.nvf.nvim = {
    vim = {
      notes.todo-comments.enable = true;

      keymaps = [
        {
          mode = "n";
          key = "<leader>st";
          action = ''
            function()
                require("snacks").picker.todo_comments()
            end
          '';
          lua = true;
          desc = "Todo";
          silent = false;
        }
        {
          mode = "n";
          key = "]t";
          action = ''function() require("todo-comments").jump_next() end'';
          lua = true;
          desc = "Next todo";
          silent = false;
        }
        {
          mode = "n";
          key = "[t";
          action = ''function() require("todo-comments").jump_prev() end'';
          lua = true;
          desc = "Prev todo";
          silent = false;
        }
      ];
    };
  };
}
