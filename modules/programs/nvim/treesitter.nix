{
  flake.modules.nixvim.nvim = {
    plugins.treesitter = {
      enable = true;
      nixGrammars = true;

      highlight.enable = true;
      indent.enable = true;
      folding.enable = true;
    };

    plugins.treesitter-context = {
      enable = true;
      settings.max_lines = 3;
    };
  };
}
