{ inputs, ... }:
{
  flake.modules.nvf.nvim.vim = {
    utility.yazi-nvim = {
      enable = true;
      setupOpts.open_for_directories = true;
    };

    keymaps =
      let
        inherit (inputs.self.lib.nvim) cmd;
      in
      [
        (cmd "n" "<leader>e" "<cmd>Yazi<cr>" "File explorer")
        (cmd "n" "<leader>E" "<cmd>Yazi cwd<cr>" "File explorer (cwd)")
      ];
  };
}
