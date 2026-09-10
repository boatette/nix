{
  flake.modules.nvf.nvim =
    { lib, pkgs, ... }:
    let
      inherit (lib.nvim.dag) entryAfter;
    in
    {
      vim = {
        treesitter = {
          enable = true;
          fold = true;

          grammars = pkgs.vimPlugins.nvim-treesitter.allGrammars;

          highlight.enable = true;
          indent.enable = true;

          context = {
            enable = true;
            setupOpts = {
              max_lines = 3;
              separator = null;
            };
          };

          queries = [
            {
              type = "injections";
              filetypes = [ "nix" ];
              loadtype = "extends";
              query = ''
                ; mkLuaInline ...
                ((apply_expression
                  function: (_) @_fn
                  argument: (indented_string_expression
                    (string_fragment) @injection.content))
                  (#lua-match? @_fn "mkLuaInline$")
                  (#set! injection.language "lua")
                  (#set! injection.combined))

                ; lua-valued attributes, directly or behind a call or lambda
                ((binding
                  attrpath: (attrpath
                    (identifier) @_path)
                  expression: [
                    (indented_string_expression
                      (string_fragment) @injection.content)
                    (apply_expression
                      argument: (indented_string_expression
                        (string_fragment) @injection.content))
                    (function_expression
                      body: (indented_string_expression
                        (string_fragment) @injection.content))
                  ])
                  (#any-of? @_path "luaConfigRC" "luaConfigPre" "luaConfigPost" "setup" "action")
                  (#set! injection.language "lua")
                  (#set! injection.combined))
              '';
            }
          ];
        };

        luaConfigRC.treesitter-context-underline = entryAfter [ "pluginConfigs" ] ''
          do
              local group = vim.api.nvim_create_augroup("TreesitterContextUnderline", { clear = true })

              local function underline()
                  local sp = vim.api.nvim_get_hl(0, { name = "Comment", link = false }).fg
                  for _, name in ipairs({ "TreesitterContextBottom", "TreesitterContextLineNumberBottom" }) do
                      vim.api.nvim_set_hl(0, name, { underline = true, sp = sp })
                  end
              end

              vim.api.nvim_create_autocmd("User", {
                  pattern = "ColourschemeApplied",
                  group = group,
                  desc = "Underline the context after a theme change",
                  callback = underline,
              })

              underline()
          end
        '';
      };
    };
}
