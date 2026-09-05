{ inputs, ... }:
{
  flake.modules.nixvim.nvim =
    { lib, pkgs, ... }:
    let
      inherit (lib.nixvim) mkRaw;
      inherit (inputs.self.constants) flakeDir;

      simpleServers =
        lib.genAttrs
          [
            "bashls"
            "eslint"
            "glsl_analyzer"
            "jsonls"
            "ols"
            "qmlls"
            "ruff"
            "ts_ls"
            "zls"
          ]
          (_: {
            enable = true;
            package = null;
          });
    in
    {
      extraPackages = with pkgs; [
        bash-language-server
        clang-tools
        glsl_analyzer
        kdePackages.qtdeclarative
        lua-language-server
        nixd
        ols
        pyright
        ruff
        typescript-language-server
        vscode-langservers-extracted
        zls
      ];

      lsp.servers = simpleServers // {
        clangd = {
          enable = true;
          package = null;

          config = {
            cmd = [
              "clangd"
              "--background-index"
              "--clang-tidy"
              "--header-insertion=never"
              "--all-scopes-completion"
              "--completion-style=detailed"
              "--function-arg-placeholders=false"
              "--fallback-style=llvm"
            ];

            root_markers = [
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

            on_init = mkRaw ''
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
        };

        lua_ls = {
          enable = true;
          package = null;

          config.on_init = mkRaw ''
            function(client)
                if client.workspace_folders then
                    local path = client.workspace_folders[1].name
                    if
                        path ~= vim.fn.stdpath("config")
                        and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
                    then
                        return
                    end
                end

                client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
                    runtime = {
                        version = "LuaJIT",
                        path = { "lua/?.lua", "lua/?/init.lua" },
                    },
                    workspace = {
                        checkThirdParty = false,
                        library = { vim.env.VIMRUNTIME },
                    },
                })
            end
          '';
        };

        nixd = {
          enable = true;
          package = null;

          config.settings = mkRaw ''
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
        };

        pyright = {
          enable = true;
          package = null;
          config.settings.python.pythonPath = mkRaw ''vim.fn.exepath("python3")'';
        };
      };
    };
}
