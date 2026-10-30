{ inputs, lib, ... }:
{
  flake.modules.nvf.nvim =
    { pkgs, ... }:
    {
      vim = {
        extraPlugins.hardtime-nvim = {
          package = pkgs.vimPlugins.hardtime-nvim;
          setup = /* lua */ ''
            require("hardtime").setup(${
              lib.generators.toLua { } {
                max_count = 3;
                restriction_mode = "block";
                disable_mouse = false;
                disabled_filetypes = {
                  snacks_picker_list = true;
                  snacks_picker_input = true;
                  snacks_terminal = true;
                  yazi = true;
                  harpoon = true;
                };
              }
            })
          '';
        };

        keymaps = [
          (inputs.self.lib.nvim.cmd "n" "<leader>oh" "<cmd>Hardtime toggle<cr>" "Toggle hardtime")
          (inputs.self.lib.nvim.cmd "n" "<leader>oH" "<cmd>Hardtime report<cr>" "Hardtime report")
        ];
      };
    };
}
