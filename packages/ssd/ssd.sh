set -uo pipefail

SSD_ROOT="${SSD_ROOT:-/mnt/storage}"
BAK_ROOT="${BAK_ROOT:-$SSD_ROOT/bak}"
STATE="${XDG_STATE_HOME:-$HOME/.local/state}"

APP="ssd"

readonly DIRS=(
    "Desktop:Desktop"
    "Documents:Documents"
    "Music:Music"
    "Pictures:Pictures"
    "Projects:Projects"
    "Videos:Videos"
    ".local/share/PrismLauncher:PrismLauncher"
    ".local/state/noctalia/plugins/data/boatette/auto-theme:auto-theme"
)

log() { printf '%s: %s\n' "$APP" "$*"; }
err() { printf '%s: %s\n' "$APP" "$*" >&2; }

usage() {
    cat <<EOF
usage: ssd <command>

  backup    mirror the home directories onto the SSD
  restore   copy them back, without overwriting anything present

Both are no-ops when \$SSD_ROOT is not mounted.

Environment:
  SSD_ROOT   mount point (default: /mnt/storage)
  BAK_ROOT   backup tree (default: \$SSD_ROOT/bak)
EOF
}

ssd_present() {
    ls "$SSD_ROOT" >/dev/null 2>&1 || true
    findmnt -rno FSTYPE "$SSD_ROOT" 2>/dev/null | grep -qvx autofs
}

cmd_backup() {
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

cmd_restore() {
    local stamp="$STATE/ssd-restore.stamp"

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
        mkdir -p "$(dirname "$stamp")"
        date -Iseconds >"$stamp"
        log "done"
    fi

    return $rc
}

cmd="${1-}"
[ $# -gt 0 ] && shift

case "$cmd" in
backup | restore)
    APP="ssd-$cmd"
    "cmd_$cmd" "$@"
    ;;
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
