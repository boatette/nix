{
  flake.modules.nvf.nvim =
    { pkgs, ... }:
    {
      vim.lazy.plugins."better-escape.nvim" = {
        package = pkgs.vimPlugins.better-escape-nvim;
        setupModule = "better_escape";
        event = [ "InsertEnter" ];

        # jk and kj rarely come up in text; the plugin types the j or k out at once instead of waiting
        setupOpts = {
          default_mappings = false;
          mappings.i = {
            j.k = "<Esc>";
            k.j = "<Esc>";
          };
        };
      };
    };
}
