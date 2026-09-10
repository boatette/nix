{
  flake.modules.nvf.nvim = {
    vim = {
      utility.yazi-nvim = {
        enable = true;
        setupOpts.open_for_directories = true;
      };

      keymaps = [
        {
          mode = "n";
          key = "<leader>e";
          action = "<cmd>Yazi<cr>";
          desc = "File explorer";
          silent = false;
        }
        {
          mode = "n";
          key = "<leader>E";
          action = "<cmd>Yazi cwd<cr>";
          desc = "File explorer (cwd)";
          silent = false;
        }
      ];
    };
  };
}
