{ writeShellApplication }:

writeShellApplication {
  name = "backup";
  meta.description = "copy a file to <file>.bak";
  text = ''
    cp -- "$1" "$1.bak"
  '';
}
