{
  flake.modules.nvf.nvim =
    { lib, pkgs, ... }:
    let
      inherit (lib.generators) mkLuaInline;
    in
    {
      vim = {
        extraPlugins.flutter-tools-nvim = {
          package = pkgs.vimPlugins.flutter-tools-nvim;
          setup = "";
        };

        augroups = [ { name = "LanguageSetup"; } ];

        autocmds = [
          {
            event = [ "FileType" ];
            pattern = [ "dart" ];
            group = "LanguageSetup";
            once = true;
            desc = "Set up flutter-tools on first Dart buffer";
            callback = mkLuaInline ''
              function()
                  require("flutter-tools").setup({
                      ui = { notification_style = "native" },
                      debugger = { enabled = true },
                      widget_guides = { enabled = true },
                      lsp = { color = { enabled = true } },
                  })
              end
            '';
          }
        ];
      };
    };
}
