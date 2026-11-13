{ inputs, ... }:
{
  flake.modules.nvf.nvim =
    { lib, pkgs, ... }:
    {
      vim = {
        extraPackages = with pkgs; [
          clang-tools
          gersemi
          gofumpt
          # only goimports; the full gotools set is ~250M
          (gotools.overrideAttrs { subPackages = [ "cmd/goimports" ]; })
          ktlint
          nixfmt
          prettierd
          ruff
          shfmt
          stylua
          taplo
        ];

        formatter.conform-nvim = {
          enable = true;

          setupOpts = {
            formatters_by_ft = {
              bash = [ "shfmt" ];
              sh = [ "shfmt" ];

              c = [ "clang_format" ];
              cmake = [ "gersemi" ];
              cpp = [ "clang_format" ];
              glsl = [ "clang_format" ];

              go = [
                "goimports"
                "gofumpt"
              ];

              kotlin = [ "ktlint" ];
              lua = [ "stylua" ];
              nix = [ "nixfmt" ];
              rust = [ "rustfmt" ];
              toml = [ "taplo" ];

              python = [
                "ruff_format"
                "ruff_organize_imports"
              ];
            }
            // lib.genAttrs [
              "css"
              "html"
              "javascript"
              "javascriptreact"
              "json"
              "jsonc"
              "markdown"
              "typescript"
              "typescriptreact"
              "yaml"
            ] (_: [ "prettierd" ]);

            format_on_save.lsp_format = "fallback";

            format_after_save = null;
          };
        };

        keymaps = [
          (inputs.self.lib.nvim.mod "n" "<leader>cf" "conform"
            ''format({ async = true, lsp_format = "fallback" })''
            "Format buffer"
          )
        ];
      };
    };

}
