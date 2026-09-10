{
  flake.modules.nvf.nvim =
    { lib, ... }:
    let
      inherit (lib.generators) mkLuaInline;
    in
    {
      vim = {
        tabline.nvimBufferline = {
          enable = true;

          setupOpts = {
            options = {
              always_show_bufferline = true;
              sort_by = "id";
              diagnostics = "nvim_lsp";
              diagnostics_update_in_insert = false;
            };

            highlights = mkLuaInline ''
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

        keymaps = [
          {
            mode = "n";
            key = "<S-h>";
            action = "<cmd>BufferLineCyclePrev<CR>";
            desc = "Prev tab";
            silent = false;
          }
          {
            mode = "n";
            key = "<S-l>";
            action = "<cmd>BufferLineCycleNext<CR>";
            desc = "Next tab";
            silent = false;
          }
        ];

        augroups = [ { name = "BufferlineTransparency"; } ];

        autocmds = [
          {
            event = [ "User" ];
            pattern = [ "ColourschemeApplied" ];
            group = "BufferlineTransparency";
            desc = "Strip bufferline backgrounds after a theme change";
            callback = mkLuaInline ''
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
    };
}
