{ writeShellApplication }:

writeShellApplication {
  name = "unowned";
  meta.description = "find files not owned by the user";
  text = ''
    find "$@" -not -user "$(whoami)"
  '';
}
