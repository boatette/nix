{
  flake.modules.nixvim.nvim =
    { lib, ... }:
    let
      inherit (lib.nixvim) mkRaw;

      harpoonSelect = n: {
        mode = "n";
        key = "<leader>${toString n}";
        action = mkRaw ''
          function()
              require("harpoon"):list():select(${toString n})
          end
        '';
        options.desc = "Harpoon: file ${toString n}";
      };
    in
    {
      plugins.oil = {
        enable = true;
        settings = {
          default_file_explorer = true;
          view_options.show_hidden = true;
          float = {
            max_width = 90;
            max_height = 30;
          };
        };
      };

      plugins.harpoon = {
        enable = true;
        enableTelescope = false;
      };

      keymaps = [
        {
          mode = "n";
          key = "<leader>e";
          action = "<cmd>Oil --float<cr>";
          options.desc = "File explorer";
        }
        {
          mode = "n";
          key = "<leader>E";
          action = "<cmd>Oil . --float<cr>";
          options.desc = "File explorer (cwd)";
        }

        {
          mode = "n";
          key = "<leader>a";
          action = mkRaw ''
            function()
                require("harpoon"):list():add()
            end
          '';
          options.desc = "Harpoon: add file";
        }
        {
          mode = "n";
          key = "<leader>h";
          action = mkRaw ''
            function()
                local harpoon = require("harpoon")
                harpoon.ui:toggle_quick_menu(harpoon:list())
            end
          '';
          options.desc = "Harpoon: menu";
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
}
