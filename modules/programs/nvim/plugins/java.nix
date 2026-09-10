{
  flake.modules.nvf.nvim =
    { lib, pkgs, ... }:
    let
      inherit (lib.generators) mkLuaInline;
    in
    {
      vim = {
        extraPackages = [ pkgs.jdt-language-server ];

        extraPlugins.nvim-java = {
          package = pkgs.vimPlugins.nvim-java;
          setup = "";
        };

        augroups = [ { name = "LanguageSetup"; } ];

        autocmds = [
          {
            event = [ "FileType" ];
            pattern = [ "java" ];
            group = "LanguageSetup";
            once = true;
            desc = "Set up nvim-java and jdtls on first Java buffer";
            callback = mkLuaInline ''
              function()
                  require("java").setup({ spring_boot_tools = { enable = false } })
                  vim.lsp.enable("jdtls")
              end
            '';
          }
        ];
      };
    };
}
