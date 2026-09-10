{
  flake.modules.nvf.nvim =
    let
      harpoonSelect = n: {
        mode = "n";
        key = "<leader>${toString n}";
        action = ''
          function()
              require("harpoon"):list():select(${toString n})
          end
        '';
        lua = true;
        desc = "Harpoon: file ${toString n}";
        silent = false;
      };
    in
    {
      vim = {
        navigation.harpoon.enable = true;

        keymaps = [
          {
            mode = "n";
            key = "<leader>a";
            action = ''
              function()
                  require("harpoon"):list():add()
              end
            '';
            lua = true;
            desc = "Harpoon: add file";
            silent = false;
          }
          {
            mode = "n";
            key = "<leader>h";
            action = ''
              function()
                  local harpoon = require("harpoon")
                  harpoon.ui:toggle_quick_menu(harpoon:list())
              end
            '';
            lua = true;
            desc = "Harpoon: menu";
            silent = false;
          }
        ]
        ++ map harpoonSelect [
          1
          2
          3
          4
          5
        ];
      };
    };
}
