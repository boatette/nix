#!/usr/bin/env bash

set -euo pipefail

REPO=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}

say() { printf '\033[32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[33m  !\033[0m %s\n' "$*" >&2; }
have() { command -v "$1" >/dev/null 2>&1; }

link_one() {
    local file=$1
    local src=$REPO/$file
    local dst=$HOME/$file

    if [[ -L $dst && $(readlink "$dst") == "$src" ]]; then
        return
    fi

    mkdir -p -- "$(dirname -- "$dst")"

    if [[ -e $dst || -L $dst ]]; then
        mv -- "$dst" "$dst.bak"
        warn "backed up $file -> $file.bak"
    fi

    ln -s -- "$src" "$dst"
}

link() {
    say "linking dotfiles into $HOME"

    local file
    while IFS= read -r -d '' file; do
        case $file in
        README.md | install.sh | .gitignore) continue ;;
        esac
        link_one "$file"
    done < <(git -C "$REPO" ls-files -z)
}

zsh_plugins() {
    local dir=$XDG_DATA_HOME/zsh/plugins
    say "cloning zsh plugins into $dir"
    mkdir -p -- "$dir"

    local repo name
    for repo in zsh-users/zsh-autosuggestions \
        zsh-users/zsh-syntax-highlighting \
        zsh-users/zsh-history-substring-search \
        Aloxaf/fzf-tab; do
        name=${repo#*/}

        if [[ -d $dir/$name/.git ]]; then
            git -C "$dir/$name" pull --quiet --ff-only || warn "could not update $name"
        else
            git clone --quiet --depth 1 "https://github.com/$repo" "$dir/$name"
        fi
    done
}

lazygit_theme() {
    local theme=$XDG_CONFIG_HOME/lazygit/config.yml
    if [[ ! -f $theme ]]; then
        mkdir -p -- "$(dirname -- "$theme")"
        printf '{}\n' >"$theme"
        say "seeded $theme"
    fi
}

yazi_plugins() {
    if ! have ya; then
        warn "ya not found, skipping yazi plugins"
        return
    fi

    say "installing yazi plugins"

    local name
    for name in chmod full-border git jump-to-char mount \
        smart-enter smart-filter smart-paste toggle-pane vcs-files; do
        ya pkg add "yazi-rs/plugins:$name" >/dev/null 2>&1 ||
            warn "could not add yazi plugin $name"
    done

    ya pkg install >/dev/null || warn "ya pkg install failed"
}

zellij_plugin() {
    local wasm=$XDG_CONFIG_HOME/zellij/plugins/autolock.wasm
    if [[ -f $wasm ]]; then
        return
    fi

    if ! have curl; then
        warn "curl not found, skipping the zellij autolock plugin"
        return
    fi

    say "fetching the zellij autolock plugin"
    mkdir -p -- "$(dirname -- "$wasm")"
    curl -fsSL -o "$wasm" \
        https://github.com/fresh2dev/zellij-autolock/releases/latest/download/zellij-autolock.wasm ||
        warn "could not fetch autolock.wasm"
}

units() {
    if ! have systemctl; then
        warn "no systemctl, skipping the user units"
        return
    fi

    say "enabling user units"
    systemctl --user daemon-reload

    local unit
    for unit in noctalia.service selector.service ssh-agent.service ssd-backup.timer; do
        systemctl --user enable "$unit" >/dev/null 2>&1 || warn "could not enable $unit"
    done
}

bootstrap() {
    zsh_plugins
    lazygit_theme
    yazi_plugins
    zellij_plugin
    units
    say "done — open nvim once to let vim.pack install its plugins"
}

case ${1:-all} in
link) link ;;
bootstrap) bootstrap ;;
all)
    link
    bootstrap
    ;;
*)
    printf 'usage: %s [link|bootstrap|all]\n' "$0" >&2
    exit 2
    ;;
esac
