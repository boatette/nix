{ inputs, ... }:
{
  flake.modules.nvf.nvim =
    { lib, pkgs, ... }:
    let
      inherit (lib.generators) mkLuaInline;
      inherit (inputs.self.constants) flakeDir;
    in
    {
      vim = {
        lsp.enable = true;

        # each language's lsp follows vim.lsp.enable, and nvf starts its server by store path
        languages =
          lib.recursiveUpdate
            (lib.genAttrs
              [
                "bash"
                "clang"
                "glsl"
                "go"
                "json"
                "lua"
                "nix"
                "odin"
                "python"
                "tsx"
                "typescript"
                "zig"
              ]
              (_: {
                enable = true;
              })
            )
            {
              nix.lsp.servers = [ "nixd" ];
              python.lsp.servers = [
                "pyright"
                "ruff"
              ];
            };

        lsp.servers = {
          clangd = {
            cmd = lib.mkForce [
              (lib.getExe' pkgs.clang-tools "clangd")
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

}
