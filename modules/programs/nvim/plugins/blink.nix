{
  flake.modules.nixvim.nvim.plugins.blink-cmp = {
    enable = true;

    settings = {
      completion = {
        accept.auto_brackets.enabled = true;
        documentation.auto_show = true;
        ghost_text.enabled = true;

        list.selection = {
          preselect = true;
          auto_insert = true;
        };

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
