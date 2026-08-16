#!/usr/bin/env bash

set -uo pipefail

theme="${XDG_CONFIG_HOME:-$HOME/.config}/foot/themes/noctalia"
[ -r "$theme" ] || exit 0

declare -A color=()
while IFS='=' read -r key value; do
    key="${key//[[:space:]]/}"
    value="${value#"${value%%[![:space:]]*}"}"
    [ -n "$key" ] && [ -n "$value" ] && color["$key"]="$value"
done < <(grep -E '^[[:space:]]*[a-z0-9-]+[[:space:]]*=' "$theme")

norm() {
    local v="${1##*[[:space:]]}"
    v="${v#\#}"
    [ "${#v}" -eq 8 ] && v="${v:2}"
    [ "${#v}" -eq 6 ] || return 1
    printf '#%s' "$v"
}

seq=""
emit() { # emit <osc-number> <raw-value>
    local hex
    hex=$(norm "${2:-}") || return 0
    # shellcheck disable=SC1003
    seq+=$(printf '\033]%s;%s\033\\' "$1" "$hex")
}

for i in 0 1 2 3 4 5 6 7; do
    emit "4;$i" "${color[regular$i]:-}"
    emit "4;$((i + 8))" "${color[bright$i]:-}"
done

emit 10 "${color[foreground]:-}"
emit 11 "${color[background]:-}"
emit 12 "${color[cursor]:-}"
emit 17 "${color[selection-background]:-}"
emit 19 "${color[selection-foreground]:-}"

[ -n "$seq" ] || exit 0

written=0
while read -r pid; do
    [ -n "$pid" ] || continue
    while read -r tty; do
        case "$tty" in
        pts/*)
            if printf '%s' "$seq" >"/dev/$tty" 2>/dev/null; then
                written=$((written + 1))
            fi
            ;;
        esac
    done < <(ps --ppid "$pid" -o tty= 2>/dev/null)
done < <(
    pgrep -x foot 2>/dev/null
    pgrep -x footclient 2>/dev/null
)

exit 0
