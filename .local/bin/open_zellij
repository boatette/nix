#!/usr/bin/env bash
set -u

save_layout() {
    if [ -z "${ZELLIJ:-}" ]; then
        printf '\e[31mNot inside a zellij session\e[0m — run this from the session you want to save.\n' >&2
        exit 1
    fi

    local dir=${1:-$PWD}
    dir=${dir/#\~/$HOME}
    if [ ! -d "$dir" ]; then
        printf '\e[31mNot a directory:\e[0m %s\n' "$dir" >&2
        exit 1
    fi

    local layout="$dir/.zellij.kdl"
    if zellij action dump-layout > "$layout"; then
        printf 'Saved session layout to \e[32m%s\e[0m\n' "$layout"
    else
        rm -f "$layout"
        printf '\e[31mFailed to dump layout\e[0m\n' >&2
        exit 1
    fi
}

case "${1:-}" in
    save)
        shift
        save_layout "$@"
        exit 0
        ;;
esac

pick_dir() {
    zoxide query -l | fzf \
        --reverse --height=100% \
        --prompt='zellij › ' \
        --header='Open Zellij in…  (type a path, Enter to confirm, Esc for a shell)' \
        --print-query | tail -1
}

session_name() {
    printf '%s' "$(basename "$1")" | tr -c 'A-Za-z0-9_-' '_'
}

session_exists() {
    zellij list-sessions -s -n 2>/dev/null | grep -qx "$1"
}

while true; do
    dir=$(pick_dir)

    if [ -z "$dir" ]; then
        exec "${SHELL:-/usr/bin/fish}"
    fi

    dir=${dir/#\~/$HOME}
    if [ ! -d "$dir" ]; then
        printf '\e[31mNot a directory:\e[0m %s\n' "$dir" >&2
        sleep 1.2
        continue
    fi

    cd "$dir" || continue
    session=$(session_name "$dir")
    layout="$dir/.zellij.kdl"

    if session_exists "$session"; then
        exec zellij attach "$session"
    elif [ -f "$layout" ]; then
        exec zellij --new-session-with-layout "$layout" --session "$session"
    else
        exec zellij --session "$session"
    fi
done
