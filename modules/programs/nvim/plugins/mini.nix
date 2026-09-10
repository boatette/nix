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

        # nixvim's plugins.mini.mockDevIcons has no nvf equivalent; nvf's
        # vim.mini.icons only ever calls setup().
        luaConfigRC.mini-mock-devicons = entryAfter [ "pluginConfigs" ] ''
          require("mini.icons").mock_nvim_web_devicons()
        '';

        keymaps = [
          {
            mode = "n";
            key = "gS";
            action = ''
              function()
                  require("mini.splitjoin").toggle()
              end
            '';
            lua = true;
            desc = "Split/join";
            silent = false;
          }
        ];
      };
    };

  flake.modules.nvf.nvim =
    { lib, pkgs, ... }:
    {
      vim = {
        # nvf has no extraFiles equivalent, so the snippet JSON is staged into a
        # directory that gets added to the runtimepath. mini.snippets' loaders
        # look for `snippets/` on the rtp, which is what this provides.
        additionalRuntimePaths = [
          (pkgs.runCommand "nvim-snippets" { } ''
            mkdir -p $out/snippets
            cp ${../snippets}/*.json $out/snippets/
          '')
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
