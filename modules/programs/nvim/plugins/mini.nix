{ inputs, ... }:
{
  flake.modules.nvf.core =
    { lib, ... }:
    let
      inherit (lib.generators) mkLuaInline;
      inherit (lib.nvim.dag) entryAfter;
    in
    {
      vim = {
        mini = {
          icons.enable = true;
          ai.enable = true;
          diff.enable = true;
          splitjoin.enable = true;

          hipatterns = {
            enable = true;
            setupOpts.highlighters.hex_color = mkLuaInline ''require("mini.hipatterns").gen_highlighter.hex_color()'';
          };

          surround = {
            enable = true;
            setupOpts.mappings = {
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

        luaConfigRC.mini-mock-devicons = entryAfter [ "pluginConfigs" ] ''
          require("mini.icons").mock_nvim_web_devicons()
        '';

        keymaps = [
          (inputs.self.lib.nvim.mod "n" "gS" "mini.splitjoin" "toggle()" "Split/join")
        ];
      };
    };

  flake.modules.nvf.nvim =
    { lib, ... }:
    {
      vim = {
        mini.snippets = {
          enable = true;
          setupOpts.snippets = lib.generators.mkLuaInline ''
            {
                require("mini.snippets").gen_loader.from_runtime("global.json"),
                require("mini.snippets").gen_loader.from_lang(),
            }
          '';
        };
      };
    };
}
