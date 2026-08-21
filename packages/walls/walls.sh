set -uo pipefail

PROG="${0##*/}"
WALLPAPERS="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
REPO="${WALLPAPER_REPO:-boatette/wallpapers}"
DEFAULT_THEMES=(Dark Dynamic Light)

die() {
    echo "$PROG: $*" >&2
    exit 1
}

# usage errors exit 2, runtime failures exit 1
usage_err() {
    echo "$PROG: $*" >&2
    exit 2
}

need_arg() {
    [ -n "${2-}" ] || usage_err "$1 needs a value"
}

lower() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }

usage() {
    cat <<EOF
usage: $PROG <command> [options]

  optimise   recompress a wallpaper tree to WebP
  pack       tar each theme out of the optimised tree
  push       upload the tarballs to a GitHub release
  pull       fetch and extract the latest release
  prune      list or delete undersized wallpapers

Run "$PROG <command> --help" for that command's options.

Environment:
  WALLPAPER_DIR   wallpaper tree (default: \$HOME/Pictures/Wallpapers)
  WALLPAPER_REPO  release repo for push/pull (default: boatette/wallpapers)
EOF
}

# ---------------------------------------------------------------- optimise

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

cmd_optimise() {
    local SRC="$WALLPAPERS" DST="" QUALITY=90 DRY=0 JOBS
    JOBS="$(nproc 2>/dev/null || echo 4)"

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
            cat <<EOF
usage: $PROG optimise [options]

  -s, --src DIR      source tree (default: \$WALLPAPER_DIR)
  -d, --dst DIR      output tree (default: <src>/.optimised)
  -q, --quality N    lossy WebP quality 0-100 (default: $QUALITY)
  -j, --jobs N       parallel workers (default: nproc)
  -n, --dry-run      classify and report, convert nothing
  -h, --help         this
EOF
            return 0
            ;;
        *)
            echo "unknown option: $1" >&2
            return 2
            ;;
        esac
    done

    SRC="${SRC%/}"
    [ -n "$DST" ] || DST="$SRC/.optimised"
    DST="${DST%/}"

    [ -d "$SRC" ] || die "no such directory: $SRC"

    if command -v cwebp >/dev/null; then
        ENCODER=cwebp
    else
        ENCODER=ffmpeg
        echo "warning: cwebp missing, using ffmpeg - ICC profiles will be dropped" >&2
    fi

    mkdir -p "$DST" || exit 1
    SRC_ABS="$(cd "$SRC" && pwd)" || exit 1
    DST_ABS="$(cd "$DST" && pwd)" || exit 1

    export -f process_one
    export SRC_ABS DST_ABS QUALITY ENCODER DRY

    echo "source:  $SRC_ABS"
    echo "output:  $DST_ABS"
    echo "encoder: $ENCODER (quality $QUALITY, $JOBS jobs)"
    if [ "$DRY" -eq 1 ]; then
        echo "mode:    DRY RUN - nothing will be written"
    fi
    echo

    # not local: the EXIT trap fires after this function has returned
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
}

# -------------------------------------------------------------------- pack

cmd_pack() {
    local OPTIMISE=1 themes=() selected=() walls src dist theme low out

    while [ $# -gt 0 ]; do
        case "$1" in
        --skip-optimise)
            OPTIMISE=0
            shift
            ;;
        -h | --help)
            cat <<EOF
usage: $PROG pack [--skip-optimise] [theme ...]

  --skip-optimise   reuse the existing .optimised tree instead of rebuilding it
  theme ...         themes to pack (default: ${DEFAULT_THEMES[*]})

Writes \$WALLPAPER_DIR/.dist/wallpapers-<theme>.tar.zst
EOF
            return 0
            ;;
        -*)
            echo "unknown option: $1" >&2
            return 2
            ;;
        *)
            selected+=("$1")
            shift
            ;;
        esac
    done

    if [ "${#selected[@]}" -gt 0 ]; then
        themes=("${selected[@]}")
    else
        themes=("${DEFAULT_THEMES[@]}")
    fi

    walls="${WALLPAPERS%/}"
    src="$walls/.optimised"
    dist="$walls/.dist"

    [ -d "$walls" ] || die "no such directory: $walls"

    if [ "$OPTIMISE" -eq 1 ]; then
        # subshell: optimise cds and sets its own globals
        (cmd_optimise --src "$walls" --dst "$src") || exit 1
        echo
    fi

    [ -d "$src" ] || die "no optimised tree at $src (run without --skip-optimise)"

    mkdir -p "$dist" || exit 1

    for theme in "${themes[@]}"; do
        if [ ! -d "$src/$theme" ]; then
            echo "skipping $theme: not in $src" >&2
            continue
        fi

        low="$(lower "$theme")"
        out="$dist/wallpapers-$low.tar.zst"

        tar -I 'zstd -1' -cf "$out" -C "$src" "$theme" || exit 1
        printf '%-40s %s\n' "$(basename "$out")" "$(du -h "$out" | cut -f1)"
    done

    echo
    echo "Tarballs in $dist"
    echo "Publish them with: $PROG push"
}

# -------------------------------------------------------------------- push

cmd_push() {
    local tag dist assets=() a name old code release_id token failed=0 asset
    tag="$(date +%Y.%m.%d)"

    while [ $# -gt 0 ]; do
        case "$1" in
        --tag)
            need_arg "$1" "${2-}"
            tag="$2"
            shift 2
            ;;
        --repo)
            need_arg "$1" "${2-}"
            REPO="$2"
            shift 2
            ;;
        -h | --help)
            cat <<EOF
usage: $PROG push [--tag TAG] [--repo OWNER/NAME]

  --tag TAG          release tag (default: today, $tag)
  --repo OWNER/NAME  target repository (default: \$WALLPAPER_REPO)

Uploads every \$WALLPAPER_DIR/.dist/wallpapers-*.tar.zst built by "$PROG pack".
EOF
            return 0
            ;;
        *)
            echo "unknown option: $1" >&2
            return 2
            ;;
        esac
    done

    dist="${WALLPAPERS%/}/.dist"

    mapfile -t assets < <(find "$dist" -maxdepth 1 -name 'wallpapers-*.tar.zst' 2>/dev/null | sort)

    [ "${#assets[@]}" -gt 0 ] || die "no tarballs in $dist - run \"$PROG pack\" first"

    gh auth status >/dev/null 2>&1 || die "not logged in to GitHub. Run: gh auth login"

    echo "repo:  $REPO"
    echo "tag:   $tag"
    echo "files:"
    for a in "${assets[@]}"; do
        printf '  %-40s %s\n' "$(basename "$a")" "$(du -h "$a" | cut -f1)"
    done
    echo

    if ! gh release view "$tag" --repo "$REPO" >/dev/null 2>&1; then
        gh release create "$tag" \
            --repo "$REPO" \
            --title "$tag" \
            --notes "Wallpaper pack $tag" || exit 1
        echo
    fi

    release_id="$(gh api "repos/$REPO/releases/tags/$tag" --jq .id)" || exit 1
    token="$(gh auth token)" || exit 1

    # not local: the EXIT trap fires after this function has returned
    resp="$(mktemp)"
    trap 'rm -f "$resp"' EXIT

    for asset in "${assets[@]}"; do
        name="$(basename "$asset")"

        old="$(gh api "repos/$REPO/releases/$release_id/assets" \
            --jq ".[] | select(.name==\"$name\") | .id" 2>/dev/null)"

        if [ -n "$old" ]; then
            gh api -X DELETE "repos/$REPO/releases/assets/$old" >/dev/null 2>&1
        fi

        echo "uploading $name"
        code="$(curl --progress-bar -X POST -T "$asset" \
            -H "Authorization: Bearer $token" \
            -H "Content-Type: application/octet-stream" \
            -H "Accept: application/vnd.github+json" \
            -o "$resp" -w '%{http_code}' \
            "https://uploads.github.com/repos/$REPO/releases/$release_id/assets?name=$name")"

        if [ "$code" = "201" ]; then
            echo "  ok"
        else
            echo "  FAILED (HTTP $code)" >&2
            head -c 400 "$resp" >&2
            echo >&2
            failed=1
        fi
    done

    [ "$failed" -eq 0 ] || exit 1

    echo
    echo "Published https://github.com/$REPO/releases/tag/$tag"
}

# -------------------------------------------------------------------- pull

cmd_pull() {
    local CLEAN=0 themes=() selected=() walls theme low asset url failed=0

    while [ $# -gt 0 ]; do
        case "$1" in
        --clean)
            CLEAN=1
            shift
            ;;
        --repo)
            need_arg "$1" "${2-}"
            REPO="$2"
            shift 2
            ;;
        -h | --help)
            cat <<EOF
usage: $PROG pull [--clean] [--repo OWNER/NAME] [theme ...]

  --clean            remove each theme directory before extracting
  --repo OWNER/NAME  source repository (default: \$WALLPAPER_REPO)
  theme ...          themes to fetch (default: ${DEFAULT_THEMES[*]})

Extracts into \$WALLPAPER_DIR (default: \$HOME/Pictures/Wallpapers).
EOF
            return 0
            ;;
        -*)
            echo "unknown option: $1" >&2
            return 2
            ;;
        *)
            selected+=("$1")
            shift
            ;;
        esac
    done

    if [ "${#selected[@]}" -gt 0 ]; then
        themes=("${selected[@]}")
    else
        themes=("${DEFAULT_THEMES[@]}")
    fi

    walls="${WALLPAPERS%/}"
    mkdir -p "$walls" || exit 1

    for theme in "${themes[@]}"; do
        low="$(lower "$theme")"
        asset="wallpapers-$low.tar.zst"
        url="https://github.com/$REPO/releases/latest/download/$asset"

        if [ "$CLEAN" -eq 1 ] && [ -d "$walls/$theme" ]; then
            echo "removing $walls/$theme"
            rm -rf "${walls:?}/$theme"
        fi

        printf 'fetching %-28s ' "$asset"
        if curl -fsSL "$url" | tar --zstd -x -C "$walls"; then
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
    echo "Wallpapers in $walls"
}

# ------------------------------------------------------------------- prune

cmd_prune() {
    local MIN_W=1920 MIN_H=1080 DELETE=0 ROTATE=0 dirs=()
    local f w h cw ch small=0 kept=0 bad=0 bytes=0

    while (($#)); do
        case "$1" in
        --delete) DELETE=1 ;;
        --any-orientation) ROTATE=1 ;;
        --min)
            [[ ${2-} =~ ^([0-9]+)x([0-9]+)$ ]] || usage_err "bad --min: ${2-}"
            MIN_W=${BASH_REMATCH[1]}
            MIN_H=${BASH_REMATCH[2]}
            shift
            ;;
        -h | --help)
            cat <<EOF
usage: $PROG prune [--delete] [--min WxH] [--any-orientation] [dir ...]

  --delete            actually remove files (default: just list them)
  --min WxH           minimum size (default: ${MIN_W}x${MIN_H})
  --any-orientation   keep portrait images that meet the threshold when
                      rotated (e.g. 1080x1920 counts as big enough)

With no dirs given, scans ${DEFAULT_THEMES[*]} under
\$WALLPAPER_DIR (default: \$HOME/Pictures/Wallpapers).
EOF
            return 0
            ;;
        -*)
            echo "unknown option: $1" >&2
            return 2
            ;;
        *) dirs+=("$1") ;;
        esac
        shift
    done

    if ((${#dirs[@]} == 0)); then
        cd "$WALLPAPERS" || exit 1
        dirs=("${DEFAULT_THEMES[@]}")
    fi

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
    done < <(find "${dirs[@]}" -type f \
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
}

# ----------------------------------------------------------------- dispatch

cmd="${1-}"
[ $# -gt 0 ] && shift

case "$cmd" in
optimise) cmd_optimise "$@" ;;
pack) cmd_pack "$@" ;;
push) cmd_push "$@" ;;
pull) cmd_pull "$@" ;;
prune) cmd_prune "$@" ;;
help | -h | --help) usage ;;
"")
    usage >&2
    exit 2
    ;;
*)
    echo "unknown command: $cmd" >&2
    usage >&2
    exit 2
    ;;
esac
