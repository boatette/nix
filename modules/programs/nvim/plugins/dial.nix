{ inputs, ... }:
{
  flake.modules.nvf.core =
    { pkgs, ... }:
    let
      dialMap =
        mode: fn: desc:
        inputs.self.lib.nvim.lua mode (if fn == "inc" then "<C-a>" else "<C-x>") /* lua */ ''
          function()
              return require("dial.map").${fn}_${if mode == "n" then "normal" else "visual"}()
          end
        '' desc
        // {
          expr = true;
        };

      keys = [
        (dialMap "n" "inc" "Increment")
        (dialMap "n" "dec" "Decrement")
        (dialMap "v" "inc" "Increment")
        (dialMap "v" "dec" "Decrement")
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
