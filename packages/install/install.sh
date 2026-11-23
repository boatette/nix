readonly EFI_GLOBAL=8be4df61-93ca-11d2-aa0d-00e098032b8c
readonly MNT=/mnt

log() { printf '\e[1;34m::\e[0m %s\n' "$*"; }
warn() { printf '\e[1;33m!!\e[0m %s\n' "$*" >&2; }
bold() { printf '\n\e[1m%s\e[0m\n' "$*"; }

die() {
  printf '\e[1;31mxx\e[0m %s\n' "$*" >&2
  exit 1
}

usage() {
  cat <<EOF
usage: install [--flake REF] [--dry-run] [-- nixos-install options]

Erase the disks $HOST's disko config names, install $HOST and set its
user passwords.

  --flake REF  flake to install from (default: the one this came from)
  --dry-run    show the plan and disko's script, change nothing
  -h, --help   show this help
EOF
}

efi_var() {
  local file="/sys/firmware/efi/efivars/$1-$EFI_GLOBAL"

  if [[ -r "$file" ]]; then
    od -An -t u1 -j4 -N1 "$file" | tr -d ' \n'
  else
    printf 0
  fi
}

ask() {
  local reply=
  read -rp "$1" reply || true
  printf '%s' "$reply"
}

ask_secret() {
  local reply=
  read -rsp "$1" reply || true
  echo >&2
  printf '%s' "$reply"
}

online() {
  curl -fs --max-time 5 -o /dev/null https://cache.nixos.org/nix-cache-info
}

args=("$@")
flake=$FLAKE
dry_run=0
extra=()

while (($#)); do
  case "$1" in
    --flake)
      (($# >= 2)) || die "--flake needs a flake reference"
      flake=$2
      shift 2
      ;;
    --dry-run)
      dry_run=1
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    --)
      shift
      extra=("$@")
      break
      ;;
    *)
      usage >&2
      die "unknown argument: $1"
      ;;
  esac
done

if ((EUID != 0 && ! dry_run)); then
  exec sudo "$0" "${args[@]}"
fi

export NIX_CONFIG="extra-experimental-features = nix-command flakes
${NIX_CONFIG:-}"

if ! online; then
  if command -v nmtui >/dev/null; then
    warn "no network, opening nmtui"
    nmtui || true
  fi
  online || die "no network; the install fetches the flake's inputs and the binary caches"
fi

[[ -d /sys/firmware/efi ]] || die "this machine was started in legacy BIOS mode; boot the stick in UEFI mode"

log "reading $HOST's install plan from $flake"
plan=$(nix eval --json "$flake#nixosConfigurations.$HOST.config.install.plan") ||
  die "could not evaluate $HOST's install plan"

field() { jq -r "$1" <<<"$plan"; }

mapfile -t disks < <(field '.disks[]')
mapfile -t tpm < <(field '.tpm[]')
mapfile -t notes < <(field '.notes[]')
mapfile -t password_files < <(field '.passwordFiles | to_entries[] | "\(.key)=\(.value)"')

substituters=$(field '.substituters | join(" ")')
trusted_keys=$(field '.trustedPublicKeys | join(" ")')

print_notes() {
  ((${#notes[@]})) || return 0
  bold "Notes for $HOST"
  printf '  - %s\n' "${notes[@]}"
}

missing=()
for disk in "${disks[@]}"; do
  [[ -e "$disk" ]] || missing+=("$disk")
done

if ((${#missing[@]})); then
  {
    printf '\e[1;31mxx\e[0m %s\n' "$HOST's disko config names disks this machine does not have:"
    printf '     %s\n' "${missing[@]}"
    echo
    echo "Disks on this machine, by their stable names:"
    for id in /dev/disk/by-id/*; do
      [[ -e "$id" && "$id" != *-part* ]] || continue
      printf '  %s -> %s\n' "$id" "$(basename "$(readlink -f "$id")")"
    done
    echo
    echo "Point a writable copy of the flake's modules/hosts/$HOST/disko.nix at the right one,"
    echo "install with --flake <copy>, and commit the change once the repo is cloned."
  } >&2
  exit 1
fi

if [[ "$(efi_var SetupMode)" != 1 ]]; then
  warn "the firmware is not in Secure Boot Setup Mode"
  cat <<EOF

$HOST generates its Secure Boot keys on first boot, and the firmware only
accepts them once its own keys are cleared (Setup Mode). Until then Secure
Boot stays off, and finish-install will not bind the disk to the TPM.
EOF
  if ((! dry_run)); then
    echo
    case "$(ask "[r]eboot into the firmware to clear the keys, [c]ontinue anyway, [a]bort? ")" in
      r | R)
        systemctl reboot --firmware-setup
        exit 0
        ;;
      c | C) ;;
      *) die "aborted, nothing was changed" ;;
    esac
  fi
fi

if ((${#tpm[@]})) && [[ ! -e /sys/class/tpm/tpm0 ]]; then
  warn "$HOST unlocks its disk with the TPM, but this machine has none; the passphrase will be asked at every boot"
fi

bold "Install $HOST from $flake"
echo "These disks will be ERASED:"
for disk in "${disks[@]}"; do
  printf '  %s\n    %s\n' "$disk" "$(lsblk -dno MODEL,SIZE "$(readlink -f "$disk")" | tr -s ' ')"
done

echo
echo "Then:"
echo "  - disko asks for the new disk encryption passphrase."
echo "    Until finish-install adds a recovery key, it is the only way into the disk."
echo "  - nixos-install installs $HOST."
echo "  - set passwords for: ${password_files[*]%%=*}"
print_notes

if ((dry_run)); then
  bold "disko script"
  disko --mode destroy,format,mount --flake "$flake#$HOST" --dry-run
  echo
  log "dry run, nothing was changed"
  exit 0
fi

echo
[[ "$(ask "Type '$HOST' to erase the disks above and install: ")" == "$HOST" ]] ||
  die "aborted, nothing was changed"

bold "Partitioning"
disko --mode destroy,format,mount --flake "$flake#$HOST" --yes-wipe-all-disks

bold "Installing"
install_args=(
  --root "$MNT"
  --flake "$flake#$HOST"
  --no-root-passwd
  --option extra-substituters "$substituters"
  --option extra-trusted-public-keys "$trusted_keys"
)

# the live system's store is in ram
if [[ "$(findmnt -no FSTYPE /)" == tmpfs ]]; then
  install_args+=(--option max-jobs 3 --option cores 4)
fi

nixos-install "${install_args[@]}" "${extra[@]}"

for entry in "${password_files[@]}"; do
  user=${entry%%=*}
  file=$MNT${entry#*=}

  bold "Password for $user"
  for attempt in 1 2 3; do
    first=$(ask_secret "New password: ")
    second=$(ask_secret "Retype new password: ")

    if [[ -n "$first" && "$first" == "$second" ]]; then
      install -d -m 700 "$(dirname "$file")"
      (umask 077 && mkpasswd -m yescrypt -s <<<"$first" >"$file")
      break
    fi

    if ((attempt == 3)); then
      warn "no password set for $user; write one with: mkpasswd | install -m 600 /dev/stdin $file"
    else
      warn "the passwords were empty or did not match"
    fi
  done
done
unset first second

bold "$HOST is installed"
echo "  1. Reboot and remove the install stick."
echo "  2. Log in and run finish-install. It says when to reboot, and when it is done."
print_notes

echo
case "$(ask "Reboot now? [Y/n] ")" in
  n | N) ;;
  *) systemctl reboot ;;
esac
