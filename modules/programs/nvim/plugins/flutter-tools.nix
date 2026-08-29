{
  flake.modules.nixvim.nvim =
    { lib, pkgs, ... }:
    let
      inherit (lib.nixvim) mkRaw;
    in
    {
      extraPlugins = [ pkgs.vimPlugins.flutter-tools-nvim ];

      autoGroups.LanguageSetup.clear = true;

      autoCmd = [
        {
          event = "FileType";
          pattern = [ "dart" ];
          group = "LanguageSetup";
          once = true;
          desc = "Set up flutter-tools on first Dart buffer";
          callback = mkRaw ''
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
}
