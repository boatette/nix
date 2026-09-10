{ inputs, ... }:
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

          setupOpts.options = {
            always_show_bufferline = true;
            numbers = "none";
            sort_by = "id";
            diagnostics = "nvim_lsp";
            diagnostics_update_in_insert = false;
          };
        };

        keymaps =
          let
            inherit (inputs.self.lib.nvim) cmd;
          in
          [
            (cmd "n" "<S-h>" "<cmd>BufferLineCyclePrev<CR>" "Prev tab")
            (cmd "n" "<S-l>" "<cmd>BufferLineCycleNext<CR>" "Next tab")
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
