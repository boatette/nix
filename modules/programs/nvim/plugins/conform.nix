{
  flake.modules.nvf.nvim =
    { pkgs, ... }:
    {
      vim = {
        extraPackages = with pkgs; [
          clang-tools
          gofumpt
          google-java-format
          gotools
          ktlint
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

              java = [ "google-java-format" ];
              kotlin = [ "ktlint" ];
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

            formatters."google-java-format".prepend_args = [ "--aosp" ];

            format_on_save.lsp_format = "fallback";

            format_after_save = null;
          };
        };

        keymaps = [
          {
            mode = "n";
            key = "<leader>cf";
            action = ''
              function()
                  require("conform").format({ async = true, lsp_format = "fallback" })
              end
            '';
            lua = true;
            desc = "Format buffer";
            silent = false;
          }
        ];
      };
    };
}
