#!/usr/bin/env bash

set -uo pipefail

WALLS="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
REPO="${WALLPAPER_REPO:-boatette/wallpapers}"
TAG="$(date +%Y.%m.%d)"

usage() {
    cat <<EOF
usage: ${0##*/} [--tag TAG] [--repo OWNER/NAME]

  --tag TAG         release tag (default: today, $TAG)
  --repo OWNER/NAME target repository (default: \$WALLPAPER_REPO)

Uploads every \$WALLPAPER_DIR/dist/wallpapers-*.tar.zst built by walls-pack.
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
    --tag)
        TAG="$2"
        shift 2
        ;;
    --repo)
        REPO="$2"
        shift 2
        ;;
    -h | --help)
        usage
        exit 0
        ;;
    *)
        echo "unknown option: $1" >&2
        usage >&2
        exit 2
        ;;
    esac
done

DIST="${WALLS%/}/dist"

mapfile -t assets < <(find "$DIST" -maxdepth 1 -name 'wallpapers-*.tar.zst' 2>/dev/null | sort)

if [ "${#assets[@]}" -eq 0 ]; then
    echo "no tarballs in $DIST - run walls-pack first" >&2
    exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
    echo "not logged in to GitHub. Run: gh auth login" >&2
    exit 1
fi

echo "repo:  $REPO"
echo "tag:   $TAG"
echo "files:"
for a in "${assets[@]}"; do
    printf '  %-40s %s\n' "$(basename "$a")" "$(du -h "$a" | cut -f1)"
done
echo

if gh release view "$TAG" --repo "$REPO" >/dev/null 2>&1; then
    echo "release $TAG exists, replacing its assets"
    gh release upload "$TAG" "${assets[@]}" --repo "$REPO" --clobber || exit 1
else
    gh release create "$TAG" "${assets[@]}" \
        --repo "$REPO" \
        --title "$TAG" \
        --notes "Wallpaper pack $TAG" || exit 1
fi

echo
echo "Published https://github.com/$REPO/releases/tag/$TAG"
