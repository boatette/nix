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

          move = {
            enable = true;
            setupOpts.mappings = {
              left = "";
              right = "";
              down = "J";
              up = "K";

              line_left = "";
              line_right = "";
              line_down = "";
              line_up = "";
            };
          };

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
        # blink's auto_brackets adds the () itself; typing ) after it just steps over
        mini.pairs = {
          enable = true;
          setupOpts.mappings =
            let
              # don't open a pair right before a word, a quote or another opener
              open = pair: {
                action = "open";
                inherit pair;
                neigh_pattern = "^[^\\][^%w%%%'%[%\"%.%`%$]";
              };
              # nor a quote pair right after or before a word
              quote = pair: prev: {
                action = "closeopen";
                inherit pair;
                neigh_pattern = "^[^\\${prev}][^%w]";
                register.cr = false;
              };
            in
            {
              "(" = open "()";
              "[" = open "[]";
              "{" = open "{}";
              "\"" = quote "\"\"" "%w";
              "'" = quote "''" "%a";
              "`" = quote "``" "%w";
            };
        };

        augroups = [ { name = "MiniPairsDisable"; } ];
        autocmds = [
          {
            event = [ "FileType" ];
            pattern = [
              "snacks_picker_input"
              "snacks_input"
            ];
            group = "MiniPairsDisable";
            desc = "No auto-pairs in prompts";
            command = "let b:minipairs_disable = v:true";
          }
        ];

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
