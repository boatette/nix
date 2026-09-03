{
  flake.modules.nixvim.core =
    { lib, ... }:
    let
      inherit (lib.nixvim) mkRaw;
    in
    {
      plugins.mini = {
        enable = true;
        mockDevIcons = true;

        modules = {
          icons = { };
          ai = { };
          splitjoin = { };

          hipatterns.highlighters.hex_color = mkRaw ''require("mini.hipatterns").gen_highlighter.hex_color()'';

          surround.mappings = {
            add = "gsa";
            delete = "gsd";
            find = "gsf";
            find_left = "gsF";
            highlight = "gsh";
            replace = "gsr";
            update_n_lines = "gsn";
          };
        };
      };

      keymaps = [
        {
          mode = "n";
          key = "gS";
          action = mkRaw ''
            function()
                require("mini.splitjoin").toggle()
            end
          '';
          options.desc = "Split/join";
        }
      ];
    };

  flake.modules.nixvim.nvim =
    { lib, ... }:
    {
      extraFiles = lib.listToAttrs (
        map
          (name: {
            name = "snippets/${name}.json";
            value.source = ../snippets/${name}.json;
          })
          [
            "bash"
            "global"
            "lua"
            "nix"
          ]
      );

      plugins.mini.modules.snippets.snippets = lib.nixvim.mkRaw ''
        {
            require("mini.snippets").gen_loader.from_runtime("global.json"),
            require("mini.snippets").gen_loader.from_lang(),
        }
      '';
    };
}
