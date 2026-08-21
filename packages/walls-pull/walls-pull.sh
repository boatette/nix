set -uo pipefail

WALLS="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
REPO="${WALLPAPER_REPO:-boatette/wallpapers}"
THEMES=(Dark Dynamic Light)
CLEAN=0

usage() {
    cat <<EOF
usage: ${0##*/} [--clean] [--repo OWNER/NAME] [theme ...]

  --clean            remove each theme directory before extracting
  --repo OWNER/NAME  source repository (default: \$WALLPAPER_REPO)
  theme ...          themes to fetch (default: ${THEMES[*]})

Extracts into \$WALLPAPER_DIR (default: \$HOME/Pictures/Wallpapers).
EOF
}

selected=()
while [ $# -gt 0 ]; do
    case "$1" in
    --clean)
        CLEAN=1
        shift
        ;;
    --repo)
        if [ -z "${2-}" ]; then
            echo "--repo needs OWNER/NAME" >&2
            exit 2
        fi
        REPO="$2"
        shift 2
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
mkdir -p "$WALLS" || exit 1

failed=0
for theme in "${THEMES[@]}"; do
    lower="$(printf '%s' "$theme" | tr '[:upper:]' '[:lower:]')"
    asset="wallpapers-$lower.tar.zst"
    url="https://github.com/$REPO/releases/latest/download/$asset"

    if [ "$CLEAN" -eq 1 ] && [ -d "$WALLS/$theme" ]; then
        echo "removing $WALLS/$theme"
        rm -rf "${WALLS:?}/$theme"
    fi

    printf 'fetching %-28s ' "$asset"
    if curl -fsSL "$url" | tar --zstd -x -C "$WALLS"; then
        echo "ok"
    else
        echo "FAILED"
        failed=1
    fi
done

if [ "$failed" -ne 0 ]; then
    echo >&2
    echo "some themes failed. Check $REPO has a release with those assets:" >&2
    echo "  gh release view --repo $REPO" >&2
    exit 1
fi

echo
echo "Wallpapers in $WALLS"
