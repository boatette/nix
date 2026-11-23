{ inputs, ... }:
{
  flake.modules.nvf.nvim =
    { lib, ... }:
    let
      inherit (lib.generators) mkLuaInline;
    in
    {
      vim = {
        mini = {
          ai.enable = true;
          diff.enable = true;
          icons.enable = true;
          splitjoin.enable = true;

          hipatterns = {
            enable = true;
            setupOpts.highlighters.hex_color = mkLuaInline ''require("mini.hipatterns").gen_highlighter.hex_color()'';
          };

          move = {
            enable = true;
            setupOpts.mappings = {
              down = "J";
              up = "K";

              left = "";
              right = "";
              line_down = "";
              line_left = "";
              line_right = "";
              line_up = "";
            };
          };

          # blink's auto_brackets adds the () itself; typing ) after it just steps over
          pairs = {
            enable = true;
            setupOpts.mappings =
              let
                # no pair right before a word, a quote or another opener
                open = pair: {
                  action = "open";
                  inherit pair;
                  neigh_pattern = "^[^\\][^%w%%%'%[%\"%.%`%$]";
                };

                # no quote pair right after or before a word
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

          snippets = {
            enable = true;
            setupOpts.snippets = mkLuaInline ''
              {
                  require("mini.snippets").gen_loader.from_runtime("global.json"),
                  require("mini.snippets").gen_loader.from_lang(),
              }
            '';
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

        # bufferline turns it on, but mini.icons stands in for it
        visuals.nvim-web-devicons.enable = lib.mkForce false;

        luaConfigRC.mini-mock-devicons = lib.nvim.dag.entryAfter [ "pluginConfigs" ] ''
          require("mini.icons").mock_nvim_web_devicons()
        '';

        autocmds = [
          {
            event = [ "FileType" ];
            pattern = [
              "snacks_input"
              "snacks_picker_input"
            ];
            desc = "No auto-pairs in prompts";
            command = "let b:minipairs_disable = v:true";
          }
        ];

        keymaps = [ (inputs.self.lib.nvim.mod "n" "gS" "mini.splitjoin" "toggle()" "Split/join") ];
      };
    };
}
