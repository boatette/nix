{
  flake.modules.nixvim.nvim =
    { lib, pkgs, ... }:
    let
      inherit (lib.nixvim) mkRaw;
    in
    {
      extraPackages = [ pkgs.jdt-language-server ];

      extraPlugins = [ pkgs.vimPlugins.nvim-java ];

      autoGroups.LanguageSetup.clear = true;

      autoCmd = [
        {
          event = "FileType";
          pattern = [ "java" ];
          group = "LanguageSetup";
          once = true;
          desc = "Set up nvim-java and jdtls on first Java buffer";
          callback = mkRaw ''
            function()
                require("java").setup({ spring_boot_tools = { enable = false } })
                vim.lsp.enable("jdtls")
            end
          '';
        }
      ];
    };
}
