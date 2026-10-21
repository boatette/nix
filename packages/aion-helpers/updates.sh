# flags the aion bar when nixos-unstable has moved past the running system's nixpkgs
flag=${XDG_RUNTIME_DIR:?}/aion-update

running=$(/run/current-system/sw/bin/nixos-version --revision)
# keep the last answer when offline
latest=$(git ls-remote https://github.com/NixOS/nixpkgs refs/heads/nixos-unstable) || exit 0
latest=${latest%%$'\t'*}
[[ -n $latest ]] || exit 0

if [[ $latest == "$running" ]]; then
  rm -f "$flag"
else
  : >"$flag"
fi
