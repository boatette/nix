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
usage: install-host [options] [host] [-- nixos-install options]

Erase the disks a host's disko config names, install the host, set its
user passwords and clone the flake into its home. Without a host, pick
one from a menu.

Options:
  --flake REF  flake to install from (default: /etc/nixos-config on the
               custom ISO)
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
flake=
host=
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
    -*)
      usage >&2
      die "unknown option: $1"
      ;;
    *)
      [[ -z "$host" ]] || die "install one host at a time"
      host=$1
      shift
      ;;
  esac
done

if ((EUID != 0 && ! dry_run)); then
  exec sudo "$0" "${args[@]}"
fi

export NIX_CONFIG="extra-experimental-features = nix-command flakes
${NIX_CONFIG:-}"

if [[ -z "$flake" ]]; then
  [[ -e /etc/nixos-config/flake.nix ]] ||
    die "no flake at /etc/nixos-config; boot the custom ISO or pass --flake"
  flake=/etc/nixos-config
fi

if ! online; then
  if command -v nmtui >/dev/null; then
    warn "no network, opening nmtui"
    nmtui || true
  fi
  online || die "no network; the install fetches the flake's inputs and the binary caches"
fi

log "finding installable hosts in $flake"

hosts_json=$(nix eval --json "$flake#nixosConfigurations" --apply \
  'cs: builtins.filter (h: h.disks != [ ]) (map (n: { name = n; disks = (builtins.getAttr n cs).config.install.plan.disks or [ ]; }) (builtins.attrNames cs))')
mapfile -t hosts < <(jq -r '.[].name' <<<"$hosts_json")
((${#hosts[@]})) || die "no host in $flake has a disko disk to install onto"

if [[ -z "$host" ]]; then
  choices=()
  for candidate in "${hosts[@]}"; do
    present=1
    while IFS= read -r disk; do
      [[ -e "$disk" ]] || present=0
    done < <(jq -r --arg host "$candidate" '.[] | select(.name == $host) | .disks[]' <<<"$hosts_json")
    ((present)) && choices+=("$candidate")
  done

  if ((! ${#choices[@]})); then
    warn "no host's disks are all on this machine, showing every installable host"
    choices=("${hosts[@]}")
  fi

  PS3="host to install: "
  select host in "${choices[@]}"; do
    [[ -n "$host" ]] && break
  done
  [[ -n "$host" ]] || die "no host chosen"
elif ! jq -e --arg host "$host" 'any(.[]; .name == $host)' <<<"$hosts_json" >/dev/null; then
  die "$host is not an installable host in $flake (installable: ${hosts[*]})"
fi

log "reading $host's install plan"
plan=$(nix eval --json "$flake#nixosConfigurations.$host.config.install.plan") ||
  die "could not evaluate $host's install plan; does it import the base type?"

field() { jq -r "$1" <<<"$plan"; }

mapfile -t disks < <(field '.disks[]')
mapfile -t luks < <(field '.luks[]')
mapfile -t tpm < <(field '.tpm[]')
mapfile -t users < <(field '.users[]')
mapfile -t notes < <(field '.notes[]')
mapfile -t password_files < <(field '.passwordFiles // {} | to_entries[] | "\(.key)=\(.value)"')

uefi=$(field .uefi)
root_password=$(field '.rootPassword != false')
secure_boot=$(field .secureBoot)
substituters=$(field '.substituters | join(" ")')
trusted_keys=$(field '.trustedPublicKeys | join(" ")')

print_notes() {
  ((${#notes[@]})) || return 0
  bold "Notes for $host"
  printf '  - %s\n' "${notes[@]}"
}

((${#disks[@]})) || die "$host has no disko disks, so there is nothing to install onto"

if [[ "$uefi" == true && ! -d /sys/firmware/efi ]]; then
  die "$host boots through UEFI, but this machine was started in legacy BIOS mode; boot the stick in UEFI mode"
fi

missing=()
for disk in "${disks[@]}"; do
  [[ -e "$disk" ]] || missing+=("$disk")
done

if ((${#missing[@]})); then
  {
    printf '\e[1;31mxx\e[0m %s\n' "$host's disko config names disks this machine does not have:"
    printf '     %s\n' "${missing[@]}"
    echo
    echo "Disks on this machine:"
    lsblk -d -e 7,11 -o NAME,MODEL,SIZE,SERIAL
    echo
    echo "Their stable names:"
    for id in /dev/disk/by-id/*; do
      [[ -e "$id" && "$id" != *-part* ]] || continue
      printf '  %s -> %s\n' "$id" "$(basename "$(readlink -f "$id")")"
    done
    echo
    echo "If this is the right machine, copy the flake somewhere writable:"
    echo "  cp -r --no-preserve=mode $flake /tmp/nix"
    echo "point /tmp/nix/modules/hosts/$host/disko.nix at one of these, and run:"
    echo "  install-host --flake /tmp/nix $host"
    echo "Commit the change from the new install once the repo is cloned."
  } >&2
  exit 1
fi

if [[ "$secure_boot" == true && "$(efi_var SetupMode)" != 1 ]]; then
  warn "the firmware is not in Secure Boot Setup Mode"
  cat <<EOF

$host generates its Secure Boot keys on first boot, and the firmware only
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
  warn "$host unlocks its disk with the TPM, but this machine has none; the passphrase will be asked at every boot"
fi

bold "Install $host from $flake"
echo "These disks will be ERASED:"
for disk in "${disks[@]}"; do
  printf '  %s\n    %s\n' "$disk" "$(lsblk -dno MODEL,SIZE "$(readlink -f "$disk")" | tr -s ' ')"
done

echo
echo "Then:"
if ((${#luks[@]})); then
  echo "  - disko asks for the new disk encryption passphrase."
  if ((${#tpm[@]})); then
    echo "    Until finish-install adds a recovery key, it is the only way into the disk."
  else
    echo "    It is the only way into the disk."
  fi
fi
if [[ "$root_password" == true ]]; then
  echo "  - nixos-install installs $host and asks for a root password."
else
  echo "  - nixos-install installs $host (root has no password)."
fi
password_users=("${users[@]}" "${password_files[@]%%=*}")
if ((${#password_users[@]})); then
  echo "  - set passwords for: ${password_users[*]}"
fi
print_notes

if ((dry_run)); then
  bold "disko script"
  disko --mode destroy,format,mount --flake "$flake#$host" --dry-run
  echo
  log "dry run, nothing was changed"
  exit 0
fi

echo
[[ "$(ask "Type '$host' to erase the disks above and install: ")" == "$host" ]] ||
  die "aborted, nothing was changed"

bold "Partitioning"
disko --mode destroy,format,mount --flake "$flake#$host" --yes-wipe-all-disks

bold "Installing"
install_args=(--root "$MNT" --flake "$flake#$host")

if [[ -n "$substituters" ]]; then
  install_args+=(--option extra-substituters "$substituters")
fi

if [[ -n "$trusted_keys" ]]; then
  install_args+=(--option extra-trusted-public-keys "$trusted_keys")
fi

if [[ "$root_password" != true ]]; then
  install_args+=(--no-root-passwd)
fi

if [[ "$(findmnt -no FSTYPE /)" == tmpfs ]]; then
  install_args+=(--option max-jobs 3 --option cores 4)
fi

nixos-install "${install_args[@]}" "${extra[@]}"

for user in "${users[@]}"; do
  bold "Password for $user"
  for attempt in 1 2 3; do
    if nixos-enter --root "$MNT" --silent -c "passwd $(printf %q "$user")"; then
      break
    fi

    if ((attempt == 3)); then
      warn "no password set for $user; set one with: nixos-enter --root $MNT -c 'passwd $user'"
    fi
  done
done

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

bold "$host is installed"
echo "  1. Reboot and remove the install stick."
echo "  2. Log in and run finish-install. It says when to reboot, and when it is done."
print_notes

echo
case "$(ask "Reboot now? [Y/n] ")" in
  n | N) ;;
  *) systemctl reboot ;;
esac
