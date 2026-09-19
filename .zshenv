export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

export EDITOR="nvim"
export SUDO_EDITOR="nvim"

export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"

export CARGO_HOME="$HOME/.cargo"
export GOPATH="$HOME/go"

export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"

export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship.toml"

export LG_CONFIG_FILE="$XDG_CONFIG_HOME/lazygit/base.yml,$XDG_CONFIG_HOME/lazygit/config.yml"

export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
export XCURSOR_THEME="capitaine-cursors"
export XCURSOR_SIZE="24"
export XCURSOR_PATH="$XDG_DATA_HOME/icons:/usr/share/icons${XCURSOR_PATH:+:}$XCURSOR_PATH"

typeset -U path
path=("$HOME/.local/bin" "$HOME/go/bin" "$HOME/.cargo/bin" $path)
export PATH

if [ -z "$SSH_AUTH_SOCK" ] || [ -z "$SSH_CONNECTION" ]; then
  export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/ssh-agent"
fi
