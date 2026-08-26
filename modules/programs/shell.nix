{
  flake.modules.nixos.shell.programs.zsh.enable = true;

  flake.modules.homeManager.shell.programs = {
    zsh = {
      enable = true;

      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      historySubstringSearch.enable = true;

      defaultKeymap = "viins";

      localVariables.KEYTIMEOUT = 1;

      history = {
        size = 100000;
        save = 100000;
        extended = true;
        ignoreDups = true;
        ignoreSpace = true;
        share = true;
      };

      initContent = ''
        for keymap in viins vicmd; do
          bindkey -M $keymap '^A' beginning-of-line
          bindkey -M $keymap '^E' end-of-line
          bindkey -M $keymap '^R' history-incremental-search-backward
        done
        unset keymap

        bindkey -M viins '^W' backward-kill-word
        bindkey -M viins '^U' backward-kill-line
        bindkey -M viins '^F' autosuggest-accept
      '';
    };

    zoxide = {
      enable = true;
      options = [ "--cmd cd" ];
      enableZshIntegration = true;
    };
  };
}
