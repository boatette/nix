{ inputs, ... }:
{
  flake.modules.nvf.core =
    { pkgs, ... }:
    let
      dial =
        mode: key: fn: desc:
        inputs.self.lib.nvim.lua mode key /* lua */ ''
          function()
              return require("dial.map").${fn}()
          end
        '' desc
        // {
          expr = true;
        };

      keys = [
        (dial "n" "<C-a>" "inc_normal" "Increment")
        (dial "n" "<C-x>" "dec_normal" "Decrement")
        (dial "v" "<C-a>" "inc_visual" "Increment")
        (dial "v" "<C-x>" "dec_visual" "Decrement")
      ];
    in
    {
      vim.lazy.plugins."dial.nvim" = {
        package = pkgs.vimPlugins.dial-nvim;
        after = ''require("config.dial")'';
        inherit keys;
      };
    };
}
