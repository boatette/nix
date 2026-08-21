{
  flake.modules.nixvim.nvim =
    { lib, ... }:
    let
      inherit (lib.nixvim) mkRaw;

      neotest = key: expr: desc: {
        mode = "n";
        inherit key;
        action = mkRaw ''
          function()
              require("neotest").${expr}
          end
        '';
        options.desc = desc;
      };
    in
    {
      plugins.neotest = {
        enable = true;

        adapters = {
          rust.enable = true;
          zig.enable = true;
          dart = {
            enable = true;
            settings.runner = "flutter";
          };
        };

        settings = {
          output.open_on_run = true;
          status = {
            virtual_text = true;
            signs = true;
          };
        };
      };

      keymaps = [
        (neotest "<leader>tr" "run.run()" "Run nearest test")
        (neotest "<leader>tf" ''run.run(vim.fn.expand("%"))'' "Run file")
        (neotest "<leader>ta" "run.run(vim.fn.getcwd())" "Run all tests")
        (neotest "<leader>ts" "run.stop()" "Stop")
        (neotest "<leader>to" "output.open({ enter = true })" "Output")
        (neotest "<leader>tO" "output_panel.toggle()" "Output panel")
        (neotest "<leader>tS" "summary.toggle()" "Summary")
      ];
    };
}
