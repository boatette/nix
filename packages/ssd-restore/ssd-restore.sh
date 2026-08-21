set -uo pipefail

readonly APP="ssd-restore"
SSD_ROOT="${SSD_ROOT:-/mnt/storage}"
BAK_ROOT="${BAK_ROOT:-$SSD_ROOT/bak}"
STAMP="${XDG_STATE_HOME:-$HOME/.local/state}/$APP.stamp"

readonly DIRS=(
    "Desktop:Desktop"
    "Documents:Documents"
    "Music:Music"
    "Pictures:Pictures"
    "Projects:Projects"
    "Videos:Videos"
    ".local/share/PrismLauncher:PrismLauncher"
)

log() { printf '%s: %s\n' "$APP" "$*"; }
err() { printf '%s: %s\n' "$APP" "$*" >&2; }

ssd_present() {
    ls "$SSD_ROOT" >/dev/null 2>&1 || true
    findmnt -rno FSTYPE "$SSD_ROOT" 2>/dev/null | grep -qvx autofs
}

main() {
    if ! ssd_present; then
        log "$SSD_ROOT is not mounted, nothing to restore"
        return 0
    fi

    if [[ ! -d "$BAK_ROOT" ]]; then
        err "no backup at $BAK_ROOT"
        return 0
    fi

    local rc=0 entry name src dst

    for entry in "${DIRS[@]}"; do
        name=${entry%%:*}
        src="$BAK_ROOT/${entry##*:}"
        dst="$HOME/$name"

        [[ -d "$src" ]] || continue

        mkdir -p "$dst" || {
            err "cannot create $dst"
            rc=1
            continue
        }

        log "restoring $name"
        rsync -a --ignore-existing "$src/" "$dst/" || {
            err "rsync failed for $name"
            rc=1
        }
    done

    if ((rc == 0)); then
        mkdir -p "$(dirname "$STAMP")"
        date -Iseconds >"$STAMP"
        log "done"
    fi

    return $rc
}

main "$@"
