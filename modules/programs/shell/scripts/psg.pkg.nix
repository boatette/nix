{ writeShellApplication }:

writeShellApplication {
  name = "psg";
  meta.description = "grep the process list without matching the grep itself";
  text = ''
    # shellcheck disable=SC2009
    ps aux | grep -v grep | grep -i -- "$@"
  '';
}
