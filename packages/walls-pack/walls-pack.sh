set -uo pipefail

WALLS="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
THEMES=(Dark Dynamic Light)
OPTIMISE=1

usage() {
    cat <<EOF
usage: ${0##*/} [--skip-optimise] [theme ...]

  --skip-optimise   reuse the existing .optimised tree instead of rebuilding it
  theme ...         themes to pack (default: ${THEMES[*]})

Writes \$WALLPAPER_DIR/.dist/wallpapers-<theme>.tar.zst
EOF
}

selected=()
while [ $# -gt 0 ]; do
    case "$1" in
    --skip-optimise)
        OPTIMISE=0
        shift
        ;;
    -h | --help)
        usage
        exit 0
        ;;
    -*)
        echo "unknown option: $1" >&2
        usage >&2
        exit 2
        ;;
    *)
        selected+=("$1")
        shift
        ;;
    esac
done

if [ "${#selected[@]}" -gt 0 ]; then
    THEMES=("${selected[@]}")
fi

WALLS="${WALLS%/}"
SRC="$WALLS/.optimised"
DIST="$WALLS/.dist"

if [ ! -d "$WALLS" ]; then
    echo "no such directory: $WALLS" >&2
    exit 1
fi

if [ "$OPTIMISE" -eq 1 ]; then
    walls-optimise --src "$WALLS" --dst "$SRC" || exit 1
    echo
fi

if [ ! -d "$SRC" ]; then
    echo "no optimised tree at $SRC (run without --skip-optimise)" >&2
    exit 1
fi

mkdir -p "$DIST" || exit 1

for theme in "${THEMES[@]}"; do
    if [ ! -d "$SRC/$theme" ]; then
        echo "skipping $theme: not in $SRC" >&2
        continue
    fi

    lower="$(printf '%s' "$theme" | tr '[:upper:]' '[:lower:]')"
    out="$DIST/wallpapers-$lower.tar.zst"

    tar -I 'zstd -1' -cf "$out" -C "$SRC" "$theme" || exit 1
    printf '%-40s %s\n' "$(basename "$out")" "$(du -h "$out" | cut -f1)"
done

echo
echo "Tarballs in $DIST"
echo "Publish them with: walls-push"
