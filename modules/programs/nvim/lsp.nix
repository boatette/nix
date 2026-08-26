{ inputs, ... }:
{
  flake.modules.nixvim.nvim =
    { lib, ... }:
    let
      inherit (lib.nixvim) mkRaw;
      inherit (inputs.self.constants) flakeDir;
    in
    {
      diagnostic.settings = {
        underline = true;
        update_in_insert = false;
        severity_sort = true;

        virtual_text.prefix = mkRaw ''
          function(diag)
              local icons = { ERROR = " 󰅚 ", WARN = " 󰀪 ", INFO = " 󰋽 ", HINT = " 󰌶 " }
              return icons[vim.diagnostic.severity[diag.severity]]
          end
        '';

        signs.text = mkRaw ''
          {
              [vim.diagnostic.severity.ERROR] = "󰅚 ",
              [vim.diagnostic.severity.WARN] = "󰀪 ",
              [vim.diagnostic.severity.INFO] = "󰋽 ",
              [vim.diagnostic.severity.HINT] = "󰌶 ",
          }
        '';
      };

      lsp.servers =
        lib.genAttrs
          [
            "bashls"
            "eslint"
            "glsl_analyzer"
            "gradle_ls"
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
          })
        // {
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

      autoGroups.nvim_lsp_attach.clear = true;

      autoCmd = [
        {
          event = "LspAttach";
          group = "nvim_lsp_attach";
          desc = "LSP on-attach configuration";
          callback = mkRaw ''
            function(ev)
                local buf = ev.buf
                local client = vim.lsp.get_client_by_id(ev.data.client_id)
                if not client then
                    return
                end

                local map = function(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc, silent = true })
                end

                map("n", "gd", "<cmd>Trouble lsp_definitions toggle<cr>", "Go to definition")
                map("n", "gr", "<cmd>Trouble lsp_references toggle<cr>", "Go to references")
                map("n", "gI", "<cmd>Trouble lsp_implementations toggle<cr>", "Go to implementations")
                map("n", "gy", "<cmd>Trouble lsp_type_definitions toggle<cr>", "Go to type definition")
                map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
                map("n", "K", vim.lsp.buf.hover, "Hover documentation")

                if client:supports_method("textDocument/inlayHint") then
                    vim.lsp.inlay_hint.enable(true, { bufnr = buf })
                    vim.keymap.set("n", "<leader>uh", function()
                        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
                    end, { desc = "Toggle inlay hints" })
                end

                if client:supports_method("textDocument/codeLens") then
                    vim.lsp.codelens.enable(true, { bufnr = buf })
                end

                if client:supports_method("textDocument/documentHighlight") then
                    local hl_group = vim.api.nvim_create_augroup("nvim_doc_hl_" .. buf, { clear = true })
                    vim.api.nvim_create_autocmd("CursorHold", {
                        buffer = buf,
                        group = hl_group,
                        callback = vim.lsp.buf.document_highlight,
                        desc = "Highlight symbol under cursor",
                    })
                    vim.api.nvim_create_autocmd("CursorMoved", {
                        buffer = buf,
                        group = hl_group,
                        callback = vim.lsp.buf.clear_references,
                        desc = "Clear highlight on cursor move",
                    })
                end
            end
          '';
        }
      ];
    };
}
