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

          setupOpts = {
            options = {
              numbers = "none";
              sort_by = "id";
            };

            highlights = mkLuaInline ''
              function(defaults)
                  local highlights = vim.deepcopy(defaults.highlights)
                  for _, highlight in pairs(highlights) do
                      highlight.bg = "NONE"
                  end
                  return highlights
              end
            '';
          };
        };

        keymaps =
          let
            inherit (inputs.self.lib.nvim) cmd;
          in
          [
            (cmd "n" "<S-h>" "<cmd>BufferLineCyclePrev<CR>" "Prev buffer")
            (cmd "n" "<S-l>" "<cmd>BufferLineCycleNext<CR>" "Next buffer")
          ];
      };
    };
}
