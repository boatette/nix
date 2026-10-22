readonly EFI_GLOBAL=8be4df61-93ca-11d2-aa0d-00e098032b8c

plan="${INSTALL_PLAN:-/etc/install-plan.json}"

log() { printf '\e[1;34m::\e[0m %s\n' "$*"; }
ok() { printf '  \e[1;32m✓\e[0m %s\n' "$*"; }
todo() { printf '  \e[1;33m•\e[0m %s\n' "$*"; }
hint() { printf '    %s\n' "$*"; }

die() {
  printf '\e[1;31mxx\e[0m %s\n' "$*" >&2
  exit 1
}

usage() {
  cat <<EOF
usage: finish-install [--check | --reenroll-tpm]

Finish what install-host started: wait for the Secure Boot keys to be
enrolled, then bind the disk to the TPM and create a recovery key, log
gh in to GitHub, and clone the flake over SSH with a new key that gh
adds to GitHub. Run it again whenever it asks; steps already done are
skipped.

  --check         report what is left, change nothing
  --reenroll-tpm  replace the TPM binding, e.g. after a firmware update
                  made the disk ask for its passphrase again

Environment:
  INSTALL_PLAN    plan to follow (default: /etc/install-plan.json)
EOF
}

mode=finish
case "${1-}" in
  "") ;;
  --check) mode=check ;;
  --reenroll-tpm) mode=reenroll ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac

[[ -r "$plan" ]] || die "no install plan at $plan"
plan=$(realpath "$plan")

if ((EUID != 0)); then
  exec sudo env INSTALL_PLAN="$plan" "$0" "$@"
fi

field() { jq -r "$1" "$plan"; }

host=$(field .host)
secure_boot=$(field .secureBoot)
pki_bundle=$(field '.pkiBundle // ""')
esp=$(field .esp)
username=$(field '.username // ""')
home=$(field '.home // ""')
flake_dir=$(field '.flakeDir // ""')
repo=$(field '.repo // ""')

mapfile -t tpm < <(field '.tpm[]')
mapfile -t notes < <(field '.notes[]')

efi_var() {
  local file="/sys/firmware/efi/efivars/$1-$EFI_GLOBAL"

  if [[ -r "$file" ]]; then
    od -An -t u1 -j4 -N1 "$file" | tr -d ' \n'
  else
    printf 0
  fi
}

offer_reboot() {
  [[ "$mode" == finish ]] || return 0

  local reply=
  read -rp "    Reboot now? [y/N] " reply || true
  if [[ "$reply" == [yY]* ]]; then
    systemctl reboot "$@"
    exit 0
  fi
}

secure_boot_step() {
  local enabled setup
  enabled=$(efi_var SecureBoot)
  setup=$(efi_var SetupMode)

  if [[ "$enabled" == 1 && "$setup" == 0 ]]; then
    ok "Secure Boot is enabled with this machine's keys"
    return 0
  fi

  if [[ ! -d "$pki_bundle/keys" ]]; then
    todo "the Secure Boot keys have not been generated"
    hint "generate-sb-keys.service creates them at boot: systemctl status generate-sb-keys"
  elif [[ "$setup" == 1 && -f "$esp/loader/keys/auto/PK.auth" ]]; then
    todo "the Secure Boot keys are staged, but not enrolled yet"
    hint "Reboot, and systemd-boot enrolls them. Then run finish-install again."
    offer_reboot
  elif [[ "$setup" == 1 ]]; then
    todo "the firmware is in Setup Mode, but no keys are staged"
    hint "prepare-sb-auto-enroll.service stages them at boot: systemctl status prepare-sb-auto-enroll"
  else
    todo "Secure Boot is off in the firmware"
    hint "Turn it on in the firmware settings, or clear the firmware's keys to Setup Mode"
    hint "if this machine's keys were never enrolled. Then run finish-install again."
    offer_reboot --firmware-setup
  fi

  return 1
}

tpm_step() {
  local dev slots rc=0
  local wipe=()

  if [[ "$mode" == reenroll ]]; then
    wipe=(--wipe-slot=tpm2)
  fi

  for dev in "${tpm[@]}"; do
    if ! slots=$(systemd-cryptenroll "$dev" 2>&1); then
      todo "cannot read the key slots on $dev"
      hint "$slots"
      rc=1
      continue
    fi

    if [[ "$mode" != reenroll ]] && grep -qw tpm2 <<<"$slots"; then
      ok "$dev unlocks with the TPM"
    elif [[ "$mode" == check ]]; then
      todo "$dev does not unlock with the TPM yet"
      rc=1
    else
      log "binding $dev to the TPM, enter its passphrase when asked"
      if systemd-cryptenroll "${wipe[@]}" --tpm2-device=auto --tpm2-pcrs=7 "$dev"; then
        ok "$dev unlocks with the TPM"
      else
        todo "could not bind $dev to the TPM"
        rc=1
      fi
    fi

    if grep -qw recovery <<<"$slots"; then
      ok "$dev has a recovery key"
    elif [[ "$mode" == check ]]; then
      todo "$dev has no recovery key yet"
      rc=1
    else
      log "creating a recovery key for $dev, enter its passphrase when asked"
      if systemd-cryptenroll --recovery-key "$dev"; then
        printf '\n\e[1;31m%s\e[0m\n' "Write this recovery key down somewhere that is not this machine."
        read -rp "Press Enter once it is written down. " _ || true
        ok "$dev has a recovery key"
      else
        todo "could not create a recovery key for $dev"
        rc=1
      fi
    fi
  done

  return "$rc"
}

as_user() { runuser -u "$username" -- "$@"; }

github_auth() {
  local reply
  # github exits 1 even when the key is accepted, which pipefail would count as a failure
  reply=$(as_user ssh -T -o BatchMode=yes git@github.com 2>&1) || true
  grep -q "successfully authenticated" <<<"$reply"
}

gh_scopes() {
  as_user gh auth status --hostname github.com 2>&1 | grep -i "token scopes"
}

gh_step() {
  if as_user gh auth status --hostname github.com >/dev/null 2>&1; then
    ok "gh is logged in to GitHub"
    return 0
  fi

  if [[ "$mode" == check ]]; then
    todo "gh is not logged in to GitHub yet"
    return 1
  fi

  # root has no session bus to reach the keyring, so the token goes in ~/.config/gh/hosts.yml
  log "logging gh in to GitHub, open the link and enter the code on any device"
  if as_user gh auth login --hostname github.com --git-protocol ssh --skip-ssh-key \
    --web --insecure-storage --scopes admin:public_key; then
    ok "gh is logged in to GitHub"
  else
    todo "could not log gh in to GitHub"
    return 1
  fi
}

gh_add_key() {
  local key=$1

  as_user gh auth status --hostname github.com >/dev/null 2>&1 || return 1

  if ! gh_scopes | grep -q admin:public_key; then
    log "gh needs permission to add SSH keys, approve it in the browser"
    as_user gh auth refresh --hostname github.com --scopes admin:public_key || return 1
  fi

  log "adding $key to GitHub with gh"
  as_user gh ssh-key add "$key.pub" --title "$username@$host" --type authentication
}

repo_step() {
  local key="$home/.ssh/id_ed25519"
  local url="git@github.com:$repo.git"

  if [[ -d "$flake_dir/.git" ]]; then
    ok "the flake is cloned to $flake_dir"
    return 0
  fi

  if [[ -e "$flake_dir" ]]; then
    todo "$flake_dir exists but is not a git repository"
    hint "Move it aside, then run finish-install again."
    return 1
  fi

  if [[ "$mode" == check ]]; then
    todo "the flake is not cloned to $flake_dir yet"
    return 1
  fi

  if [[ ! -f "$key" ]]; then
    log "creating an SSH key for $username, set a passphrase or leave it empty"
    as_user mkdir -p -m 700 "$home/.ssh"
    as_user ssh-keygen -q -t ed25519 -C "$username@$host" -f "$key" ||
      {
        todo "could not create $key"
        return 1
      }
  fi

  if ! github_auth && ! gh_add_key "$key"; then
    todo "gh could not add $key to GitHub"
  fi

  until github_auth; do
    log "add this key to GitHub at https://github.com/settings/ssh/new"
    printf '\n%s\n\n' "$(cat "$key.pub")"

    local reply=
    read -rp "    Press Enter once it is added, or s to skip: " reply || reply=s
    if [[ "$reply" == [sS]* ]]; then
      todo "GitHub does not accept $key yet"
      return 1
    fi
  done
  ok "GitHub accepts $key"

  log "cloning $url to $flake_dir"
  if as_user git clone "$url" "$flake_dir"; then
    ok "the flake is cloned to $flake_dir"
  else
    todo "could not clone $url"
    return 1
  fi
}

printf '\e[1m%s\e[0m\n' "Finishing the install of $host"
pending=0

if [[ "$secure_boot" == true ]] && ! secure_boot_step; then
  pending=1
fi

if ((${#tpm[@]})); then
  if ((pending)); then
    todo "binding the disk to the TPM waits for Secure Boot, since enrolling its keys changes what the TPM measures"
  elif ! tpm_step; then
    pending=1
  fi
elif [[ "$mode" == reenroll ]]; then
  die "$host has no disk that unlocks with the TPM"
fi

if [[ "$mode" != reenroll && -n "$username" ]] && ! gh_step; then
  pending=1
fi

if [[ "$mode" != reenroll && -n "$username" && -n "$flake_dir" && -n "$repo" ]] && ! repo_step; then
  pending=1
fi

if ((${#notes[@]})); then
  printf '\n\e[1m%s\e[0m\n' "Notes for $host"
  printf '  - %s\n' "${notes[@]}"
fi

echo
if ((pending)); then
  if [[ "$mode" == check ]]; then
    log "not finished; run finish-install to do the steps above"
  else
    log "not finished; run finish-install again once the steps above are done"
  fi
  exit 1
fi

log "$host is fully set up"
