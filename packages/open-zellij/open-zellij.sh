set -u

red() { printf '\e[31m%s\e[0m %s\n' "$1" "${2-}" >&2; }

expand_home() { printf '%s' "${1/#\~/$HOME}"; }

save_layout() {
    if [ -z "${ZELLIJ:-}" ]; then
        red "Not inside a zellij session" "- run this from the session you want to save."
        exit 1
    fi

    local dir layout
    dir=$(expand_home "${1:-$PWD}")

    if [ ! -d "$dir" ]; then
        red "Not a directory:" "$dir"
        exit 1
    fi

    layout="$dir/.zellij.kdl"

    if zellij action dump-layout >"$layout"; then
        printf 'Saved session layout to \e[32m%s\e[0m\n' "$layout"
    else
        rm -f "$layout"
        red "Failed to dump layout"
        exit 1
    fi
}

if [ "${1:-}" = save ]; then
    shift
    save_layout "$@"
    exit 0
fi

pick_dir() {
    zoxide query -l | fzf \
        --reverse --height=100% \
        --prompt='zellij › ' \
        --header='Open Zellij in…  (type a path, Enter to confirm, Esc for a shell)' \
        --print-query | tail -1
}

session_name() {
    basename "$1" | tr -c 'A-Za-z0-9_-' '_'
}

session_exists() {
    zellij list-sessions -s -n 2>/dev/null | grep -qx "$1"
}

while true; do
    dir=$(pick_dir)

    if [ -z "$dir" ]; then
        exec "${SHELL:-/usr/bin/fish}"
    fi

    dir=$(expand_home "$dir")

    if [ ! -d "$dir" ]; then
        red "Not a directory:" "$dir"
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
