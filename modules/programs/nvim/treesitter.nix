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

    extraConfigLuaPost = ''
      do
          local group = vim.api.nvim_create_augroup("TreesitterContextUnderline", { clear = true })

          local function underline()
              local sp = vim.api.nvim_get_hl(0, { name = "Comment", link = false }).fg
              for _, name in ipairs({ "TreesitterContextBottom", "TreesitterContextLineNumberBottom" }) do
                  vim.api.nvim_set_hl(0, name, { underline = true, sp = sp })
              end
          end

          vim.api.nvim_create_autocmd("User", {
              pattern = "ColourschemeApplied",
              group = group,
              desc = "Underline the context after a theme change",
              callback = underline,
          })

          underline()
      end
    '';
  };
}
