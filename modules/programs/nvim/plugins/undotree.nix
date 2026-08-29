{
  flake.modules.nixvim.core = {
    plugins.undotree.enable = true;

    keymaps = [
      {
        mode = "n";
        key = "<leader>ou";
        action = "<cmd>UndotreeToggle<cr>";
        options.desc = "Toggle undo tree";
      }
    ];
  };
}
