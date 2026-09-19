typeset -U path cdpath fpath manpath

ZSH_PLUGIN_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"

zsh_plugin() {
  local plugin=$1 file
  for file in "$ZSH_PLUGIN_DIR/$plugin/$plugin.plugin.zsh" "$ZSH_PLUGIN_DIR/$plugin/$plugin.zsh"; do
    [[ -r $file ]] && { source "$file"; return; }
  done
}

bindkey -v

KEYTIMEOUT="1"
autoload -U compinit && compinit

zsh_plugin fzf-tab

zsh_plugin zsh-autosuggestions
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

if [ -z "$_NOCTALIA_FZF_THEME" ] && [ -r "${XDG_CONFIG_HOME:-$HOME/.config}/fzf/themes/noctalia.sh" ]; then
  . "${XDG_CONFIG_HOME:-$HOME/.config}/fzf/themes/noctalia.sh"
  export _NOCTALIA_FZF_THEME=1
fi

command -v zoxide >/dev/null && eval "$(zoxide init zsh --cmd cd)"

HISTSIZE="100000"
SAVEHIST="100000"

HISTFILE="$HOME/.zsh_history"
mkdir -p "$(dirname "$HISTFILE")"

if [[ $options[zle] = on ]] && command -v fzf >/dev/null; then
  source <(fzf --zsh)
fi

set_opts=(
  AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT INTERACTIVE_COMMENTS
  HIST_REDUCE_BLANKS NO_FLOW_CONTROL NO_BEEP HIST_FCNTL_LOCK EXTENDED_HISTORY
  HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY NO_APPEND_HISTORY
  NO_HIST_EXPIRE_DUPS_FIRST NO_HIST_FIND_NO_DUPS NO_HIST_IGNORE_ALL_DUPS
  NO_HIST_SAVE_NO_DUPS
)
for opt in "${set_opts[@]}"; do
  setopt "$opt"
done
unset opt set_opts

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

mkcd() { mkdir -p -- "$1" && cd "$1"; }

unowned() { find "$@" -not -user "$USER"; }

function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXX")"
  command yazi "$@" --cwd-file="$tmp"
  if cwd="$(<"$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

zstyle ':completion:*' matcher-list \
  "" \
  'm:{a-z}={A-Za-z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'

zstyle ':completion:*' complete-in-word true
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' group-name ""
zstyle ':completion:*:descriptions' format '[%d]'

zstyle ':completion:*' use-cache true
zstyle ':completion:*' cache-path ${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache
[[ -d ${XDG_CACHE_HOME:-$HOME/.cache}/zsh ]] || mkdir -p ${XDG_CACHE_HOME:-$HOME/.cache}/zsh

zstyle ':completion:*' menu no

zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons auto -- $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always --icons auto -- $realpath'

if [[ $TERM != "dumb" ]] && command -v starship >/dev/null; then
  eval "$(starship init zsh)"
fi

command -v direnv >/dev/null && eval "$(direnv hook zsh)"

alias -- ..='cd ..'
alias -- ...='cd ../..'
alias -- ....='cd ../../..'
alias -- .....='cd ../../../..'
alias -- ......='cd ../../../../..'
alias -- ZQ=exit
alias -- baklog='journalctl --user -u ssd-backup -n 50 --no-pager'
alias -- baknow='systemctl --user start ssd-backup.service'
alias -- bakstatus='systemctl --user list-timers ssd-backup.timer'
alias -- c=clear
alias -- cat=bat
alias -- cealr=clear
alias -- celar=clear
alias -- cls=clear
alias -- copy='cp -r'
alias -- d='dirs -v'
alias -- dc=cd
alias -- du=dust
alias -- extract='ouch decompress'
alias -- ff=fastfetch
alias -- ga='git add'
alias -- gaa='git add -A'
alias -- gb='git branch'
alias -- gc='git commit'
alias -- gca='git commit --amend --no-edit'
alias -- gcl='git clone'
alias -- gcm='git commit -m'
alias -- gd='git diff'
alias -- gds='git diff --staged'
alias -- gf='git fetch --all --prune'
alias -- gl='git log --oneline'
alias -- glg='git log --oneline --graph --decorate --all'
alias -- gpull='git pull'
alias -- gpush='git push'
alias -- gs='git status'
alias -- gst='git stash'
alias -- gstp='git stash pop'
alias -- gsw='git switch'
alias -- gswc='git switch -c'
alias -- gundo='git reset --soft HEAD~1'
alias -- h=history
alias -- history='fc -li 1'
alias -- jctl='journalctl -p 3 -xb'
alias -- l.='eza -a | grep -e "^\."'
alias -- la='eza -a --color=always --group-directories-first --icons auto'
alias -- lg=lazygit
alias -- ll='eza -l --color=always --group-directories-first --icons auto'
alias -- ls='eza -al --color=always --group-directories-first --icons auto'
alias -- lt='eza -aT --color=always --group-directories-first --icons auto'
alias -- myip='curl -s ifconfig.me'
alias -- paths='tr '\'':'\'' '\''\n'\'' <<< $PATH'
alias -- please=run0
alias -- ports='ss -tulpn'
alias -- psg='ps aux | grep -v grep | grep -i --'
alias -- psmem='ps auxf | sort -nr -k 4'
alias -- psmem10='ps auxf | sort -nr -k 4 | head -10'
alias -- q=exit
alias -- reboot='systemctl reboot'
alias -- serve='python3 -m http.server'
alias -- shutdown='systemctl poweroff'
alias -- tarnow='tar -acf'
alias -- temps=sensors
alias -- topcpu='ps auxf | sort -nr -k 3 | head -10'
alias -- untar='tar -zxvf'
alias -- v=nvim
alias -- vim=nvim
alias -- wget='wget -c'
alias -- wifi=nmtui
alias -- z=zellij
alias -- zd='zellij --layout dev'

zsh_plugin zsh-syntax-highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)

zsh_plugin zsh-history-substring-search
bindkey "^[[A" history-substring-search-up
bindkey "^P" history-substring-search-up
bindkey "^[[B" history-substring-search-down
bindkey "^N" history-substring-search-down

bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

autoload -Uz add-zle-hook-widget

_zsh_cursor_shape() {
  case ${KEYMAP-} in
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
