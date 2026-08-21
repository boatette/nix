set -uo pipefail

MIN_W=1920
MIN_H=1080
DELETE=0
ROTATE=0
DIRS=()

usage() {
    cat <<-EOF
	usage: ${0##*/} [--delete] [--min WxH] [--any-orientation] [dir ...]

	  --delete            actually remove files (default: just list them)
	  --min WxH           minimum size (default: ${MIN_W}x${MIN_H})
	  --any-orientation   keep portrait images that meet the threshold when
	                      rotated (e.g. 1080x1920 counts as big enough)

	With no dirs given, scans Dark/ Dynamic/ Light/ under
	\$WALLPAPER_DIR (default: \$HOME/Pictures/Wallpapers).
	EOF
}

while (($#)); do
    case "$1" in
    --delete) DELETE=1 ;;
    --any-orientation) ROTATE=1 ;;
    --min)
        [[ ${2-} =~ ^([0-9]+)x([0-9]+)$ ]] || {
            echo "bad --min: ${2-}" >&2
            exit 2
        }
        MIN_W=${BASH_REMATCH[1]}
        MIN_H=${BASH_REMATCH[2]}
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
    *) DIRS+=("$1") ;;
    esac
    shift
done

if ((${#DIRS[@]} == 0)); then
    cd "${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}" || exit 1
    DIRS=(Dark Dynamic Light)
fi

command -v magick >/dev/null || {
    echo "need imagemagick (magick)" >&2
    exit 1
}

small=0
kept=0
bad=0
bytes=0

while IFS= read -r -d '' f; do
    read -r w h <<<"$(magick identify -format '%w %h' "$f" 2>/dev/null)"

    [[ $w =~ ^[0-9]+$ && $h =~ ^[0-9]+$ ]] || {
        echo "unreadable: $f" >&2
        ((++bad))
        continue
    }

    cw=$w ch=$h
    if ((ROTATE && cw < ch)); then
        cw=$h ch=$w
    fi

    if ((cw < MIN_W || ch < MIN_H)); then
        ((++small))
        ((bytes += $(stat -c %s "$f")))

        if ((DELETE)); then
            rm -- "$f" && echo "removed  ${w}x${h}  $f"
        else
            echo "would remove  ${w}x${h}  $f"
        fi
    else
        ((++kept))
    fi
done < <(find "${DIRS[@]}" -type f \
    \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \
    -o -iname '*.gif' -o -iname '*.bmp' -o -iname '*.tif' -o -iname '*.tiff' \
    -o -iname '*.avif' -o -iname '*.jxl' \) -print0 | sort -z)

echo
if ((DELETE)); then
    echo "removed $small file(s), freed $(numfmt --to=iec "$bytes")"
else
    echo "$small file(s) under ${MIN_W}x${MIN_H} ($(numfmt --to=iec "$bytes")); rerun with --delete to remove"
fi
echo "kept $kept, unreadable $bad"
