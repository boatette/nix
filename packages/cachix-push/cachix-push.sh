cache=${CACHIX_CACHE:-boatette}

withheld='^/nix/store/[a-z0-9]{32}-(claude-code|ventoy|stremio-linux-shell|vimplugin-neotest-dart)-[0-9]'

roots=("$@")
if [ ${#roots[@]} -eq 0 ]; then
    roots=("$(readlink -f /run/current-system)")
fi

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

printf '%s\n' "${roots[@]}" | sort -u >"$work/roots"
nix-store --check-validity --print-invalid "${roots[@]}" | sort >"$work/unbuilt"
comm -23 "$work/roots" "$work/unbuilt" >"$work/built"

if [ ! -s "$work/built" ]; then
    echo "nothing built to push"
    exit 0
fi

xargs nix-store --query --requisites <"$work/built" | sort -u >"$work/closure"
grep -E "$withheld" "$work/closure" >"$work/unfree" || true

if [ -s "$work/unfree" ]; then
    xargs nix-store --query --referrers-closure <"$work/unfree" | sort -u >"$work/tainted"
else
    : >"$work/tainted"
fi

comm -12 "$work/closure" "$work/tainted" >"$work/held"
comm -23 "$work/closure" "$work/tainted" >"$work/push"

if [ -s "$work/held" ]; then
    echo "withholding $(wc -l <"$work/held") paths:"
    sed -E 's#^/nix/store/[a-z0-9]{32}-#  #' "$work/held"
fi

cachix push "$cache" <"$work/push"
