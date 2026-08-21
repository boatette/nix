set -uo pipefail

readonly APP="ssd-backup"
SSD_ROOT="${SSD_ROOT:-/mnt/storage}"
BAK_ROOT="${BAK_ROOT:-$SSD_ROOT/bak}"

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
        log "$SSD_ROOT is not mounted, nothing to do"
        return 0
    fi

    mkdir -p "$BAK_ROOT" || {
        err "cannot create $BAK_ROOT"
        return 1
    }

    local rc=0 entry name src dst

    for entry in "${DIRS[@]}"; do
        name=${entry%%:*}
        src="$HOME/$name"
        dst="$BAK_ROOT/${entry##*:}"

        if [[ ! -d "$src" ]] || [[ -z "$(ls -A "$src" 2>/dev/null)" ]]; then
            log "skipping $name (missing or empty)"
            continue
        fi

        log "backing up $name"
        rsync -a --delete "$src/" "$dst/" || {
            err "rsync failed for $name"
            rc=1
        }
    done

    ((rc == 0)) && log "done"
    return $rc
}

main "$@"
