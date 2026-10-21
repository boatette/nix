{ inputs, ... }:
{
  flake.modules.nvf.nvim =
    { lib, ... }:
    let
      inherit (lib.generators) mkLuaInline;
      inherit (inputs.self.lib.nvim) cmd;

      preset = path: mkLuaInline ''require("markview.presets").${path}'';
    in
    {
      vim = {
        languages.markdown = {
          enable = true;

          lsp.enable = false;

          extensions.markview-nvim = {
            enable = true;

            setupOpts = {
              preview = {
                icon_provider = "mini";

                # render everywhere, but show the raw line under the cursor
                modes = [
                  "n"
                  "no"
                  "c"
                  "i"
                ];
                hybrid_modes = [
                  "n"
                  "i"
                ];
                linewise_hybrid_mode = true;
              };

              markdown = {
                tables = preset "tables.rounded";
                horizontal_rules = preset "horizontal_rules.thick";
              };

              markdown_inline.checkboxes = preset "checkboxes.nerd";
            };
          };
        };

        # browser preview: mermaid, KaTeX, PlantUML, charts
        utility.preview.markdownPreview.enable = true;
        globals.mkdp_theme = "dark";

        # :Checkbox, :Heading and :Editor commands register on require
        luaConfigRC.markview-extras = lib.nvim.dag.entryAfter [ "pluginConfigs" ] ''
          require("markview.extras.checkboxes").setup()
          require("markview.extras.headings").setup()
          require("markview.extras.editor").setup()
        '';

        keymaps = [
          (cmd "n" "<leader>mp" "<cmd>MarkdownPreviewToggle<cr>" "Browser preview")
          (cmd "n" "<leader>mt" "<cmd>Markview toggle<cr>" "Toggle rendering")
          (cmd "n" "<leader>ms" "<cmd>Markview splitToggle<cr>" "Split preview")
          (cmd "n" "<leader>mh" "<cmd>Markview hybridToggle<cr>" "Toggle hybrid mode")
          (cmd "n" "<leader>ml" "<cmd>Markview linewiseToggle<cr>" "Toggle linewise hybrid")
          (cmd "n" "<leader>mx" "<cmd>Checkbox toggle<cr>" "Toggle checkbox")
          (cmd "n" "<leader>mc" "<cmd>Checkbox interactive<cr>" "Change checkbox state")
          (cmd "n" "<leader>me" "<cmd>Editor edit<cr>" "Edit code block")
          (cmd "n" "<leader>mE" "<cmd>Editor create<cr>" "Create code block")
          (cmd "n" "<leader>m]" "<cmd>Heading increase<cr>" "Increase heading level")
          (cmd "n" "<leader>m[" "<cmd>Heading decrease<cr>" "Decrease heading level")
        ];
      };
    };
}
