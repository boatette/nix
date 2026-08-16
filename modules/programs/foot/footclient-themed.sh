#!/usr/bin/env bash

set -uo pipefail

theme="${XDG_CONFIG_HOME:-$HOME/.config}/foot/themes/noctalia"

trim() {
    local v="$1"
    v="${v#"${v%%[![:space:]]*}"}"
    printf '%s' "${v%"${v##*[![:space:]]}"}"
}

args=()
section="colors-dark"

if [ -r "$theme" ]; then
    while IFS= read -r line; do
        line=$(trim "$line")

        case "$line" in
        '' | '#'* | ';'*) continue ;;
        '['*']')
            section="${line#\[}"
            section="${section%\]}"
            continue
            ;;
        esac

        [ "${line#*=}" != "$line" ] || continue

        key=$(trim "${line%%=*}")
        value=$(trim "${line#*=}")
        [ -n "$key" ] && [ -n "$value" ] || continue

        args+=(--override "$section.$key=$value")
    done <"$theme"
fi

exec footclient "${args[@]}" "$@"
