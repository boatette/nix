{
  flake.modules.nvf.nvim =
    { lib, pkgs, ... }:
    let
      inherit (lib.generators) mkLuaInline;
    in
    {
      vim = {
        extraPackages = with pkgs; [
          cpplint
          deadnix
          eslint_d
          golangci-lint
          markdownlint-cli2
          ruff
          shellcheck
          statix
        ];

        diagnostics.nvim-lint = {
          enable = true;

          linters_by_ft = {
            cpp = [ "cpplint" ];
            go = [ "golangcilint" ];
            markdown = [ "markdownlint-cli2" ];

            javascript = [ "eslint_d" ];
            javascriptreact = [ "eslint_d" ];
            typescript = [ "eslint_d" ];
            typescriptreact = [ "eslint_d" ];

            nix = [
              "statix"
              "deadnix"
            ];
          };

          lint_after_save = false;
        };

        augroups = [ { name = "Lint"; } ];

        autocmds = [
          {
            event = [
              "BufWritePost"
              "BufReadPost"
            ];
            group = "Lint";
            desc = "Auto-lint on read and save";
            callback = mkLuaInline ''
              function(args)
                  nvf_lint(args.buf)
              end
            '';
          }
        ];
      };
    };

  flake.modules.nvf.nvim-full =
    { pkgs, ... }:
    {
      vim = {
        extraPackages = [ pkgs.ktlint ];

        diagnostics.nvim-lint.linters_by_ft.kotlin = [ "ktlint" ];
      };
    };
}
