usage() {
  echo "usage: spotbye-bump <SpotBye-X.Y.Z.AppImage> [version]" >&2
  exit 1
}

[[ $# -ge 1 && -f $1 ]] || usage
appimage=$(realpath "$1")

if [[ $# -ge 2 ]]; then
  version=$2
elif [[ $(basename "$appimage") =~ ^SpotBye-([0-9][0-9.]*)\.AppImage$ ]]; then
  version=${BASH_REMATCH[1]}
else
  echo "can't read a version from the file name, pass it as the second argument" >&2
  usage
fi

# requireFile looks the file up by name, so the store path has to be called exactly this
name="SpotBye-$version.AppImage"

# the only copy outside the store, which ssd backs up, so a reinstall can add it back
keep="${XDG_DATA_HOME:-$HOME/.local/share}/spotbye"
mkdir -p "$keep"
if [[ $appimage != "$keep/$name" ]]; then
  cp "$appimage" "$keep/$name.tmp"
  find "$keep" -maxdepth 1 -name 'SpotBye-*.AppImage' -delete
  mv "$keep/$name.tmp" "$keep/$name"
fi

nix-store --add-fixed sha256 "$keep/$name"
hash=$(nix hash file "$keep/$name")

sed -i \
  -e "s|^  version = \".*\";|  version = \"$version\";|" \
  -e "s|^    hash = \".*\";|    hash = \"$hash\";|" \
  "$PACKAGE"

if ! grep -qF "version = \"$version\";" "$PACKAGE" || ! grep -qF "hash = \"$hash\";" "$PACKAGE"; then
  echo "couldn't update $PACKAGE, edit it by hand: version $version, hash $hash" >&2
  exit 1
fi

# only the package file, so anything else staged in the flake stays out of the commit
if git -C "$FLAKE" diff --quiet HEAD -- "$PACKAGE"; then
  echo "spotbye was already $version, nothing to commit"
else
  git -C "$FLAKE" commit --quiet --message "feat(spotbye): $version" -- "$PACKAGE"
fi

echo "spotbye is now $version, rebuild to install it"
