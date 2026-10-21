{
  flake.modules.nvf.nvim =
    { pkgs, ... }:
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
      };
    };
}
