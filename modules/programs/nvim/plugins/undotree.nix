{ inputs, ... }:
{
  flake.modules.nvf.core.vim = {
    utility.undotree.enable = true;

    keymaps = [
      (inputs.self.lib.nvim.cmd "n" "<leader>ou" "<cmd>UndotreeToggle<cr>" "Toggle undo tree")
    ];
  };
}
