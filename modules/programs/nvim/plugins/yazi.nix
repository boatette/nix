{
  flake.modules.nixvim.nvim = {
    plugins.yazi = {
      enable = true;
      settings.open_for_directories = true;
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>Yazi<cr>";
        options.desc = "File explorer";
      }
      {
        mode = "n";
        key = "<leader>E";
        action = "<cmd>Yazi cwd<cr>";
        options.desc = "File explorer (cwd)";
      }
    ];
  };
}
