{
  flake.modules.nvf.nvim =
    { lib, pkgs, ... }:
    let
      inherit (lib.generators) mkLuaInline;
    in
    {
      vim = {
        extraPackages = with pkgs; [
          deadnix
          markdownlint-cli2
          statix
        ];

        diagnostics.nvim-lint = {
          enable = true;

          linters_by_ft = {
            go = [ "golangcilint" ];
            markdown = [ "markdownlint-cli2" ];

            nix = [
              "statix"
              "deadnix"
            ];
          }
          // lib.genAttrs [
            "javascript"
            "javascriptreact"
            "typescript"
            "typescriptreact"
          ] (_: [ "eslint_d" ]);

          lint_after_save = false;
        };

        autocmds = [
          {
            event = [
              "BufWritePost"
              "BufReadPost"
            ];
            desc = "Auto-lint on read and save";
            # golangci-lint checks the whole package, too slow to run on every open
            callback = mkLuaInline ''
              function(args)
                  if args.event == "BufReadPost" and vim.bo[args.buf].filetype == "go" then
                      return
                  end

                  -- golangci-lint and eslint_d come from project devshells, so skip linters not on PATH
                  require("lint").try_lint(nil, {
                      filter = function(linter)
                          local cmd = type(linter.cmd) == "function" and linter.cmd() or linter.cmd
                          return vim.fn.executable(cmd) == 1
                      end,
                  })
              end
            '';
          }
        ];
      };
    };

}
