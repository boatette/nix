{ writeShellApplication }:

writeShellApplication {
  name = "nsh";
  meta.description = "open a shell with packages from nixpkgs";
  text = ''
    args=()
    for p in "$@"; do
        args+=("nixpkgs#$p")
    done
    exec nix shell "''${args[@]}"
  '';
}
