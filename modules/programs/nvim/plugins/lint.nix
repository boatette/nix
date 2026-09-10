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
          ktlint
          markdownlint-cli2
          ruff
          shellcheck
          statix
        ];

        diagnostics.nvim-lint = {
          enable = true;

          linters_by_ft = {
            bash = [ "shellcheck" ];
            sh = [ "shellcheck" ];

            cpp = [ "cpplint" ];
            go = [ "golangcilint" ];
            kotlin = [ "ktlint" ];
            markdown = [ "markdownlint-cli2" ];
            python = [ "ruff" ];

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

        augroups = [ { name = "nvim_lint"; } ];

        autocmds = [
          {
            event = [
              "BufWritePost"
              "BufReadPost"
              "InsertLeave"
            ];
            group = "nvim_lint";
            desc = "Auto-lint on save and text change";
            callback = mkLuaInline ''
              function(args)
                  nvf_lint(args.buf)
              end
            '';
          }
        ];
      };
    };
}
