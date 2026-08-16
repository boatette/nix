{ writeShellApplication }:

writeShellApplication {
  name = "nrun";
  meta.description = "run a package from nixpkgs without installing";
  text = ''
    pkg="$1"
    shift
    exec nix run "nixpkgs#$pkg" -- "$@"
  '';
}
