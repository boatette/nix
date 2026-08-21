{
  flake.modules.nixvim.nvim =
    { lib, pkgs, ... }:
    let
      inherit (lib.nixvim) mkRaw;
    in
    {
      extraPackages = with pkgs; [
        lldb
        clang-tools
        cpplint
        glsl_analyzer

        fish-lsp

        jdt-language-server
        google-java-format
        ktlint

        typescript-language-server
        vscode-langservers-extracted
        eslint_d
        prettierd
        vscode-js-debug

        lua-language-server
        stylua

        markdownlint-cli2

        nixd
        nixfmt
        statix
        deadnix

        ols

        pyright
        ruff
        (python3.withPackages (ps: [ ps.debugpy ]))

        kdePackages.qtdeclarative

        rust-analyzer

        bash-language-server
        shfmt

        zls
      ];

      extraPlugins = with pkgs.vimPlugins; [
        nvim-dap-view
        flutter-tools-nvim
        nvim-java
      ];

      plugins.rustaceanvim = {
        enable = true;

        settings = {
          tools.hover_actions.replace_builtin_hover = true;

          server.default_settings."rust-analyzer" = {
            cargo.allFeatures = true;
            checkOnSave = true;
            check.command = "clippy";
            inlayHints.enable = true;
            procMacro.enable = true;
          };

          dap.adapter = {
            type = "executable";
            command = "lldb-dap";
            name = "lldb";
          };
        };
      };

      autoGroups.LanguageSetup.clear = true;

      autoCmd = [
        {
          event = "FileType";
          pattern = [ "dart" ];
          group = "LanguageSetup";
          once = true;
          desc = "Set up flutter-tools on first Dart buffer";
          callback = mkRaw ''
            function()
                require("flutter-tools").setup({
                    ui = { notification_style = "native" },
                    debugger = { enabled = true },
                    widget_guides = { enabled = true },
                    lsp = { color = { enabled = true } },
                })
            end
          '';
        }

        {
          event = "FileType";
          pattern = [ "java" ];
          group = "LanguageSetup";
          once = true;
          desc = "Set up nvim-java and jdtls on first Java buffer";
          callback = mkRaw ''
            function()
                require("java").setup({ spring_boot_tools = { enable = false } })
                vim.lsp.enable("jdtls")
            end
          '';
        }
      ];
    };
}
