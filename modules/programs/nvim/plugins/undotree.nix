{
  flake.modules.nvf.core = {
    vim = {
      utility.undotree.enable = true;

      keymaps = [
        {
          mode = "n";
          key = "<leader>ou";
          action = "<cmd>UndotreeToggle<cr>";
          desc = "Toggle undo tree";
          silent = false;
        }
      ];
    };
  };
}
