{
  flake.modules.nvf.core =
    { pkgs, ... }:
    let
      spider = motion: {
        mode = [
          "n"
          "o"
          "x"
        ];
        key = motion;
        action = ''function() require("spider").motion("${motion}") end'';
        lua = true;
        desc = "Spider-${motion}";
        silent = false;
      };
    in
    {
      vim = {
        extraPlugins.nvim-spider = {
          package = pkgs.vimPlugins.nvim-spider;
          setup = ''require("spider").setup({})'';
        };

        keymaps = map spider [
          "w"
          "e"
          "b"
          "ge"
        ];
      };
    };
}
