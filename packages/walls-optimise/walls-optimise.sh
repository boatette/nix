set -uo pipefail

SRC="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
DST=""
QUALITY=90
JOBS="$(nproc 2>/dev/null || echo 4)"
DRY=0

usage() {
    cat <<EOF
usage: ${0##*/} [options]

  -s, --src DIR      source tree (default: \$WALLPAPER_DIR)
  -d, --dst DIR      output tree (default: <src>/.optimised)
  -q, --quality N    lossy WebP quality 0-100 (default: $QUALITY)
  -j, --jobs N       parallel workers (default: nproc)
  -n, --dry-run      classify and report, convert nothing
  -h, --help         this
EOF
}

need_arg() {
    if [ -z "${2-}" ]; then
        echo "$1 needs a value" >&2
        exit 2
    fi
}

while [ $# -gt 0 ]; do
    case "$1" in
    -s | --src)
        need_arg "$1" "${2-}"
        SRC="$2"
        shift 2
        ;;
    -d | --dst)
        need_arg "$1" "${2-}"
        DST="$2"
        shift 2
        ;;
    -q | --quality)
        need_arg "$1" "${2-}"
        QUALITY="$2"
        shift 2
        ;;
    -j | --jobs)
        need_arg "$1" "${2-}"
        JOBS="$2"
        shift 2
        ;;
    -n | --dry-run)
        DRY=1
        shift
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

SRC="${SRC%/}"
[ -n "$DST" ] || DST="$SRC/.optimised"
DST="${DST%/}"

if [ ! -d "$SRC" ]; then
    echo "no such directory: $SRC" >&2
    exit 1
fi

if command -v cwebp >/dev/null; then
    ENCODER=cwebp
else
    ENCODER=ffmpeg
    echo "warning: cwebp missing, using ffmpeg - ICC profiles will be dropped" >&2
fi

mkdir -p "$DST" || exit 1
SRC_ABS="$(cd "$SRC" && pwd)" || exit 1
DST_ABS="$(cd "$DST" && pwd)" || exit 1

process_one() {
    local rel="$1"
    local in="$SRC_ABS/$rel"
    local outdir base stem ext insize

    outdir="$DST_ABS/$(dirname "$rel")"
    base="$(basename "$rel")"
    stem="${base%.*}"
    ext="$(printf '%s' "${base##*.}" | tr '[:upper:]' '[:lower:]')"

    insize=$(stat -c%s "$in" 2>/dev/null) || return 0

    emit() { printf '%s\t%s\t%s\t%s\n' "$1" "$insize" "$2" "$rel"; }

    keep_original() {
        if [ "$DRY" -eq 0 ]; then
            mkdir -p "$outdir" && cp -p "$in" "$outdir/$base"
        fi
        emit "$1" "$insize"
    }

    case "$ext" in
    png) ;;
    *)
        keep_original copy
        return 0
        ;;
    esac

    local pf
    pf=$(ffprobe -v error -select_streams v:0 -show_entries stream=pix_fmt \
        -of csv=p=0 "$in" 2>/dev/null)

    case "$pf" in
    yuv*)
        if [ "$DRY" -eq 0 ]; then
            mkdir -p "$outdir" && cp -p "$in" "$outdir/$stem.jpg"
        fi
        emit rename-jpg "$insize"
        return 0
        ;;
    rgb48* | rgba64*)
        keep_original keep-png-16bit
        return 0
        ;;
    esac

    local mode="lossy" noalpha=0 label

    if [ "$pf" = "pal8" ]; then
        mode="lossless"
    elif [ "$pf" = "rgba" ]; then
        local ymin
        ymin=$(ffmpeg -v error -i "$in" \
            -vf "alphaextract,signalstats,metadata=print:key=lavfi.signalstats.YMIN:file=-" \
            -f null - 2>/dev/null | grep -oE 'YMIN=[0-9]+' | head -1 | cut -d= -f2)

        if [ "${ymin:-0}" = "255" ]; then
            noalpha=1
        fi
    fi

    label="$mode"
    if [ "$noalpha" -eq 1 ]; then
        label="$mode-noalpha"
    fi

    if [ "$DRY" -eq 1 ]; then
        emit "$label" "$insize"
        return 0
    fi

    mkdir -p "$outdir" || return 0

    local out="$outdir/$stem.webp"
    local tmp="$out.tmp$$"

    if [ "$ENCODER" = "cwebp" ]; then
        local args=(-quiet -mt -metadata icc)
        if [ "$mode" = "lossless" ]; then
            args+=(-lossless -z 9)
        else
            args+=(-q "$QUALITY")
        fi
        if [ "$noalpha" -eq 1 ]; then
            args+=(-noalpha)
        fi
        cwebp "${args[@]}" "$in" -o "$tmp" 2>/dev/null
    else
        local args=(-v error -y -i "$in" -c:v libwebp -compression_level 6)
        if [ "$mode" = "lossless" ]; then
            args+=(-lossless 1)
        else
            args+=(-quality "$QUALITY")
        fi
        if [ "$noalpha" -eq 1 ]; then
            args+=(-pix_fmt yuv420p)
        fi
        ffmpeg "${args[@]}" "$tmp" 2>/dev/null
    fi

    if [ ! -s "$tmp" ]; then
        rm -f "$tmp"
        keep_original failed-kept-original
        return 0
    fi

    local outsize
    outsize=$(stat -c%s "$tmp")

    if [ "$outsize" -ge "$insize" ]; then
        rm -f "$tmp"
        keep_original not-smaller-kept-original
        return 0
    fi

    mv -f "$tmp" "$out"
    touch -r "$in" "$out"
    emit "$label" "$outsize"
}

export -f process_one
export SRC_ABS DST_ABS QUALITY ENCODER DRY

echo "source:  $SRC_ABS"
echo "output:  $DST_ABS"
echo "encoder: $ENCODER (quality $QUALITY, $JOBS jobs)"
if [ "$DRY" -eq 1 ]; then
    echo "mode:    DRY RUN - nothing will be written"
fi
echo

LOG="$(mktemp)"
trap 'rm -f "$LOG"' EXIT

cd "$SRC_ABS" || exit 1

find . -name '.?*' -type d -prune -o -type f -print0 |
    sed -z 's|^\./||' |
    xargs -0 -P "$JOBS" -I{} "$BASH" -c 'process_one "$@"' _ {} \
        >"$LOG"

awk -F'\t' '
{ act[$1]++; bin[$1]+=$2; bout[$1]+=$3; tin+=$2; tout+=$3; n++ }
END {
    if (n == 0) { print "no files found"; exit }
    rule = "---------------------------- ------ ------------ ------------ --------"
    printf "%-28s %6s %12s %12s %8s\n", "ACTION", "FILES", "BEFORE", "AFTER", "SAVED"
    print rule
    fflush("")
    for (a in act) {
        saved = bin[a] > 0 ? 100 * (1 - bout[a]/bin[a]) : 0
        printf "%-28s %6d %9.1f MB %9.1f MB %7.1f%%\n", a, act[a], bin[a]/1048576, bout[a]/1048576, saved | "sort"
    }
    close("sort")
    print rule
    printf "%-28s %6d %9.1f MB %9.1f MB %7.1f%%\n", "TOTAL", n, tin/1048576, tout/1048576, 100*(1-tout/tin)
}' "$LOG"

echo
if [ "$DRY" -eq 1 ]; then
    echo "Dry run complete. Re-run without --dry-run to write $DST_ABS"
else
    echo "Done. Originals untouched in $SRC_ABS"
fi
