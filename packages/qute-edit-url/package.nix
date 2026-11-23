{
  writeShellApplication,

  searxng ? "http://127.0.0.1:8192",
}:
writeShellApplication {
  name = "qute-edit-url";
  meta.description = "qutebrowser userscript that opens the url for editing, or the query on a searxng search";

  runtimeEnv.SEARXNG = searxng;

  text = builtins.readFile ./qute-edit-url.sh;
}
