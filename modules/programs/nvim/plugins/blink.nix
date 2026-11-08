{
  flake.modules.nvf.nvim.vim.autocomplete.blink-cmp = {
    enable = true;

    setupOpts = {
      completion = {
        ghost_text.enabled = true;

        menu.draw.columns = [
          [ "source_name" ]
          [ "kind_icon" ]
          [ "label" ]
          [ "kind" ]
        ];

        trigger = {
          prefetch_on_insert = true;
          show_in_snippet = false;
        };
      };

      keymap.preset = "super-tab";

      snippets.preset = "mini_snippets";
      signature.enabled = true;
    };
  };
}
