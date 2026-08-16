{ writeShellApplication }:

writeShellApplication {
  name = "copy";
  meta.description = "cp, recursing automatically when the source is a directory";
  text = ''
    if [ "$#" -eq 2 ] && [ -d "$1" ]; then
        cp -r "''${1%/}" "$2"
    else
        cp "$@"
    fi
  '';
}
