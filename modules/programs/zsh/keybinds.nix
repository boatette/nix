{
  flake.modules.homeManager.zsh =
    { lib, ... }:
    {
      programs.zsh.initContent = lib.mkMerge [
        (lib.mkOrder 1000 ''
          WORDCHARS='*?_-.[]~&;!#$%^(){}<>'

          for keymap in viins vicmd; do
            bindkey -M $keymap '^A' beginning-of-line
            bindkey -M $keymap '^E' end-of-line
          done
          unset keymap

          bindkey -M viins '^W' backward-kill-word
          bindkey -M viins '^U' backward-kill-line
          bindkey -M viins '^F' autosuggest-accept

          if (( $+widgets[fzf-history-widget] )); then
            bindkey -M viins '^R' fzf-history-widget
            bindkey -M vicmd '^R' fzf-history-widget
          else
            bindkey -M viins '^R' history-incremental-search-backward
            bindkey -M vicmd '^R' history-incremental-search-backward
          fi

          autoload -Uz edit-command-line
          zle -N edit-command-line
          bindkey -M viins '^X^E' edit-command-line
          bindkey -M vicmd '^X^E' edit-command-line

          autoload -Uz select-bracketed select-quoted
          zle -N select-bracketed
          zle -N select-quoted
          for m in visual viopp; do
            for c in {a,i}{'(',')','[',']','{','}','<','>',b,B}; do
              bindkey -M $m $c select-bracketed
            done
            for c in {a,i}{\',\",\`}; do
              bindkey -M $m $c select-quoted
            done
          done
          unset m c

          autoload -Uz surround
          zle -N delete-surround surround
          zle -N add-surround surround
          zle -N change-surround surround
          bindkey -M vicmd cs change-surround
          bindkey -M vicmd ds delete-surround
          bindkey -M vicmd ys add-surround
          bindkey -M visual S add-surround
        '')

        (lib.mkOrder 1300 ''
          bindkey -M vicmd 'k' history-substring-search-up
          bindkey -M vicmd 'j' history-substring-search-down

          if [[ "$GHOSTTY_SHELL_FEATURES" != *cursor* ]]; then
            autoload -Uz add-zle-hook-widget

            _zsh_cursor_shape() {
              case ''${KEYMAP-} in
                vicmd | visual) printf '\e[2 q' ;;
                *) printf '\e[6 q' ;;
              esac
            }
            _zsh_cursor_reset() { printf '\e[0 q'; }

            zle -N _zsh_cursor_shape
            zle -N _zsh_cursor_reset
            add-zle-hook-widget keymap-select _zsh_cursor_shape
            add-zle-hook-widget line-init _zsh_cursor_shape
            add-zle-hook-widget line-finish _zsh_cursor_reset
          fi
        '')
      ];
    };
}
