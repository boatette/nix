{
  flake.modules.nvf.nvim-full =
    { pkgs, ... }:
    {
      vim = {
        extraPackages = [ pkgs.jdt-language-server ];

        lazy.plugins.nvim-java = {
          package = pkgs.vimPlugins.nvim-java;
          setupModule = "java";
          setupOpts.spring_boot_tools.enable = false;

          ft = "java";
          after = ''vim.lsp.enable("jdtls")'';
        };
      };
    };
}
