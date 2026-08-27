{
  flake.modules.nixvim.nvim =
    { lib, ... }:
    let
      inherit (lib.nixvim) mkRaw;
    in
    {
      plugins = {
        snacks = {
          enable = true;

          settings = {
            bigfile = { };
            bufdelete = { };
            quickfile = { };

            indent.animate.enabled = false;
            terminal.win.position = "bottom";

            lazygit.win = {
              style = "float";
              position = "float";
            };

            notifier = {
              top_down = false;
              style = mkRaw ''
                function(buf, notif, ctx)
                    ctx.opts.border = "top"
                    ctx.opts.title = { { " " .. notif.icon .. (notif.title or ""), ctx.hl.title } }
                    ctx.opts.title_pos = "left"

                    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(notif.msg, "\n"))
                end
              '';
            };

            picker = {
              layout = "custom";

              sources.files = {
                hidden = true;
                follow = true;
              };

              layouts = mkRaw ''
                {
                    custom = {
                        layout = {
                            box = "vertical",
                            backdrop = true,
                            row = 1000,
                            width = 0,
                            height = 0.4,
                            border = "top",
                            title = " {title} {live} {flags}",
                            title_pos = "left",
                            {
                                box = "horizontal",
                                { win = "list", border = "none" },
                                { win = "preview", title = "{preview}", width = 0.6, border = "left" },
                            },
                            { win = "input", height = 1 },
                        },
                    },
                }
              '';
            };
          }
          //
            lib.genAttrs
              [
                "animate"
                "dashboard"
                "debug"
                "dim"
                "explorer"
                "gh"
                "git"
                "gitbrowse"
                "health"
                "image"
                "input"
                "keymap"
                "profiler"
                "rename"
                "scope"
                "scratch"
                "scroll"
                "statuscolumn"
                "toggle"
                "util"
                "win"
                "words"
                "zen"
              ]
              (_: {
                enabled = false;
              });
        };

        bufferline = {
          enable = true;

          settings = {
            options = {
              always_show_bufferline = true;
              sort_by = "id";
              diagnostics = "nvim_lsp";
              diagnostics_update_in_insert = false;
            };

            highlights = mkRaw ''
              function(defaults)
                  local hl = vim.deepcopy(defaults.highlights)
                  for _, group in pairs(hl) do
                      if type(group) == "table" then
                          group.bg = "NONE"
                      end
                  end
                  return hl
              end
            '';
          };
        };

        markview.enable = true;
        todo-comments.enable = true;
        trouble.enable = true;
      };

      autoGroups.BufferlineTransparency.clear = true;

      autoCmd = [
        {
          event = "User";
          pattern = [ "ColourschemeApplied" ];
          group = "BufferlineTransparency";
          desc = "Strip bufferline backgrounds after a theme change";
          callback = mkRaw ''
            function()
                for name in pairs(vim.api.nvim_get_hl(0, {})) do
                    if name:match("^BufferLine") or name:match("^TabLine") then
                        local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
                        if hl.bg ~= nil then
                            hl.bg = nil
                            vim.api.nvim_set_hl(0, name, hl)
                        end
                    end
                end
            end
          '';
        }
      ];
    };
}
