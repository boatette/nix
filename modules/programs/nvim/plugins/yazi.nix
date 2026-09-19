{
  flake.modules.nvf.nvim.vim = {
    utility.yazi-nvim = {
      enable = true;
      setupOpts.open_for_directories = true;

      mappings.openYazi = "<leader>e";
      mappings.openYaziDir = "<leader>E";
    };
  };
}
