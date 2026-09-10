{ inputs, ... }:
{
  flake.modules.nvf.nvim =
    { pkgs, ... }:
    {
      vim = {
        extraPackages = with pkgs; [
          clang-tools
          gofumpt
          gotools
          nixfmt
          prettierd
          ruff
          shfmt
          stylua
        ];

        formatter.conform-nvim = {
          enable = true;

          setupOpts = {
            formatters_by_ft = {
              bash = [ "shfmt" ];
              sh = [ "shfmt" ];

              c = [ "clang_format" ];
              cpp = [ "clang_format" ];
              glsl = [ "clang_format" ];

              go = [
                "goimports"
                "gofumpt"
              ];

              lua = [ "stylua" ];
              nix = [ "nixfmt" ];
              rust = [ "rustfmt" ];

              python = [
                "ruff_format"
                "ruff_organize_imports"
              ];

              javascript = [ "prettierd" ];
              javascriptreact = [ "prettierd" ];
              typescript = [ "prettierd" ];
              typescriptreact = [ "prettierd" ];
              json = [ "prettierd" ];
              jsonc = [ "prettierd" ];
              markdown = [ "prettierd" ];
            };

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

  flake.modules.nvf.nvim-full =
    { pkgs, ... }:
    {
      vim = {
        extraPackages = with pkgs; [
          google-java-format
          ktlint
        ];

        formatter.conform-nvim.setupOpts = {
          formatters_by_ft = {
            java = [ "google-java-format" ];
            kotlin = [ "ktlint" ];
          };

          formatters."google-java-format".prepend_args = [ "--aosp" ];
        };
      };
    };
}
