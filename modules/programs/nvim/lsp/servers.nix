{ inputs, ... }:
{
  flake.modules.nvf.nvim =
    { lib, pkgs, ... }:
    let
      inherit (lib.generators) mkLuaInline;
      inherit (inputs.self.constants) flakeDir;

      lspOnly =
        lib.genAttrs
          [
            "bash"
            "clang"
            "glsl"
            "go"
            "json"
            "lua"
            "nix"
            "typescript"
            "zig"
          ]
          (_: {
            enable = true;
            lsp.enable = true;
          });
    in
    {
      vim = {
        lsp.enable = true;

        extraPackages = with pkgs; [
          bash-language-server
          clang-tools
          glsl_analyzer
          gopls
          lua-language-server
          nixd
          pyright
          ruff
          typescript-language-server
          vscode-langservers-extracted
          zls
        ];

        languages = lib.recursiveUpdate lspOnly {
          nix.lsp.servers = [ "nixd" ];
          clang.lsp.servers = [ "clangd" ];

          python = {
            enable = true;
            lsp = {
              enable = true;
              servers = [
                "pyright"
                "ruff"
              ];
            };
          };
        };

        lsp.servers = {
          eslint = {
            enable = true;
            cmd = [
              "${pkgs.vscode-langservers-extracted}/bin/vscode-eslint-language-server"
              "--stdio"
            ];
            filetypes = [
              "javascript"
              "javascriptreact"
              "typescript"
              "typescriptreact"
            ];
            root_markers = [
              ".eslintrc"
              ".eslintrc.js"
              ".eslintrc.json"
              "eslint.config.js"
              "eslint.config.mjs"
              "package.json"
              ".git"
            ];
          };

          clangd = {
            cmd = lib.mkForce [
              "${pkgs.clang-tools}/bin/clangd"
              "--background-index"
              "--clang-tidy"
              "--header-insertion=never"
              "--all-scopes-completion"
              "--completion-style=detailed"
              "--function-arg-placeholders=false"
              "--fallback-style=llvm"
            ];

            root_markers = lib.mkForce [
              ".clangd"
              ".clang-tidy"
              ".clang-format"
              "compile_commands.json"
              "compile_flags.txt"
              "configure.ac"
              ".git"
              "CMakeLists.txt"
              "Makefile"
            ];

            on_init = mkLuaInline ''
              function(client)
                  client.server_capabilities.offsetEncoding = "utf-8"
              end
            '';

            settings.clangd.InlayHints = {
              Designators = true;
              Enabled = true;
              ParameterNames = true;
              DeducedTypes = true;
            };
          };

          lua-language-server.on_init = mkLuaInline ''require("config.luals").on_init'';

          nixd.settings = mkLuaInline ''
            (function()
                local flake = vim.fn.expand("${flakeDir}")
                local self = string.format('(builtins.getFlake "%s")', flake)
                local host = string.format('%s.nixosConfigurations."%s"', self, vim.fn.hostname())

                return {
                    nixd = {
                        nixpkgs = { expr = host .. ".pkgs" },
                        options = {
                            nixos = { expr = host .. ".options" },
                            home_manager = {
                                expr = host .. ".options.home-manager.users.type.getSubOptions []",
                            },
                        },
                    },
                }
            end)()
          '';

          pyright.settings.python.pythonPath = mkLuaInline ''vim.fn.exepath("python3")'';
        };
      };
    };

  flake.modules.nvf.nvim-full =
    { pkgs, ... }:
    {
      vim = {
        extraPackages = [
          pkgs.ols
          pkgs.kdePackages.qtdeclarative
        ];

        languages = {
          odin = {
            enable = true;
            lsp.enable = true;
          };

          qml = {
            enable = true;
            lsp.enable = true;
          };
        };
      };
    };
}
