{ inputs, ... }:
{
  flake.modules.nvf.nvim =
    { lib, pkgs, ... }:
    let
      neotest = key: expr: inputs.self.lib.nvim.mod "n" key "neotest" expr;

      keys = [
        (neotest "<leader>tr" "run.run()" "Run nearest test")
        (neotest "<leader>tf" ''run.run(vim.fn.expand("%"))'' "Run file")
        (neotest "<leader>ta" "run.run(vim.fn.getcwd())" "Run all tests")
        (neotest "<leader>ts" "run.stop()" "Stop")
        (neotest "<leader>to" "output.open({ enter = true })" "Output")
        (neotest "<leader>tO" "output_panel.toggle()" "Output panel")
        (neotest "<leader>tS" "summary.toggle()" "Summary")
      ];
    in
    {
      vim = {
        startPlugins = with pkgs.vimPlugins; [
          nvim-nio
          neotest-golang
          neotest-rust
          neotest-zig
          neotest-dart
        ];

        lazy.plugins.neotest = {
          package = null;
          load = "";
          setupModule = "neotest";

          setupOpts = lib.generators.mkLuaInline ''
            {
                adapters = {
                    require("neotest-golang"),
                    require("neotest-rust"),
                    require("neotest-zig"),
                    require("neotest-dart")({ runner = "flutter" }),
                },
                output = { open_on_run = true },
                status = { virtual_text = true, signs = true },
            }
          '';

          inherit keys;
        };
      };
    };
}
