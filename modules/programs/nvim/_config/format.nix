{ lib, ... }:

let
  inherit (lib.nixvim) mkRaw;
in
{
  plugins.conform-nvim = {
    enable = true;

    autoInstall.enable = false;

    settings = {
      formatters_by_ft = {
        bash = [ "shfmt" ];
        c = [ "clang_format" ];
        cpp = [ "clang_format" ];
        glsl = [ "clang_format" ];
        java = [ "google-java-format" ];
        javascript = [ "prettierd" ];
        javascriptreact = [ "prettierd" ];
        json = [ "prettierd" ];
        jsonc = [ "prettierd" ];
        kotlin = [ "ktlint" ];
        rust = [ "rustfmt" ];
        lua = [ "stylua" ];
        markdown = [ "prettierd" ];
        nix = [ "nixfmt" ];
        python = [
          "ruff_format"
          "ruff_organize_imports"
        ];
        sh = [ "shfmt" ];
        typescript = [ "prettierd" ];
        typescriptreact = [ "prettierd" ];
        zig = [ "zigfmt" ];
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
}
