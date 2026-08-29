{
  flake.modules.nixvim.nvim =
    { lib, pkgs, ... }:
    let
      inherit (lib.nixvim) mkRaw;
    in
    {
      extraPackages = with pkgs; [
        clang-tools
        google-java-format
        ktlint
        nixfmt
        prettierd
        ruff
        shfmt
        stylua
      ];

      plugins.conform-nvim = {
        enable = true;
        autoInstall.enable = false;

        settings = {
          formatters_by_ft = {
            bash = [ "shfmt" ];
            sh = [ "shfmt" ];

            c = [ "clang_format" ];
            cpp = [ "clang_format" ];
            glsl = [ "clang_format" ];

            java = [ "google-java-format" ];
            kotlin = [ "ktlint" ];
            lua = [ "stylua" ];
            nix = [ "nixfmt" ];
            rust = [ "rustfmt" ];
            zig = [ "zigfmt" ];

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
        };
      };

      keymaps = [
        {
          mode = "n";
          key = "<leader>cf";
          action = mkRaw ''
            function()
                require("conform").format({ async = true, lsp_format = "fallback" })
            end
          '';
          options.desc = "Format buffer";
        }
      ];
    };
}
