{ inputs, ... }:
{
  flake.modules.nvf.nvim =
    let
      inherit (inputs.self.lib.nvim) lua;

      harpoon =
        key: expr:
        lua "n" key /* lua */ ''
          function()
              require("harpoon")${expr}
          end
        '';

      harpoonSelect =
        n: harpoon "<leader>${toString n}" ":list():select(${toString n})" "Harpoon: file ${toString n}";
    in
    {
      vim = {
        navigation.harpoon.enable = true;

        keymaps = [
          (harpoon "<leader>a" ":list():add()" "Harpoon: add file")

          (lua "n" "<leader>h" /* lua */ ''
            function()
                local harpoon = require("harpoon")
                harpoon.ui:toggle_quick_menu(harpoon:list())
            end
          '' "Harpoon: menu")
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
