{ writeShellApplication }:

writeShellApplication {
  name = "paths";
  meta.description = "print PATH one entry per line";
  text = ''
    printf '%s' "$PATH" | tr ':' '\n'
  '';
}
