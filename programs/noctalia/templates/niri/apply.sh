#!/usr/bin/env bash
set -euo pipefail

resolve_config_home() {
    if [ -n "${XDG_CONFIG_HOME:-}" ]; then
        printf '%s\n' "$XDG_CONFIG_HOME"
        return
    fi

    if [ -z "${HOME:-}" ]; then
        echo "error: HOME or XDG_CONFIG_HOME must be set" >&2
        exit 1
    fi

    printf '%s/.config\n' "$HOME"
}

config_dir="$(resolve_config_home)/niri"
config_file="$config_dir/config.kdl"
include_line='include "noctalia.kdl"'

has_noctalia_include() {
    grep -Eq '^[[:space:]]*include([[:space:]].*)?"([^"]*/)?noctalia\.kdl"([[:space:]]|$)' "$config_file"
}

main() {
    mkdir -p "$config_dir"

    if [ ! -f "$config_file" ]; then
        printf '%s\n' "$include_line" >"$config_file"
        return
    fi

    if has_noctalia_include; then
        return
    else
        local grep_status=$?
        if [ "$grep_status" -ne 1 ]; then
            echo "error: failed to inspect $config_file" >&2
            exit "$grep_status"
        fi
    fi

    printf '\n%s\n' "$include_line" >>"$config_file"
}

main "$@"
