{ writeShellApplication }:
writeShellApplication {
  name = "qute-edit-url";
  meta.description = "qutebrowser userscript that opens the url for editing, or the query on a startpage search";

  text = builtins.readFile ./qute-edit-url.sh;
}
