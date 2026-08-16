{ writeShellApplication, python3 }:

writeShellApplication {
  name = "serve";
  meta.description = "serve the current dir over http, default port 8000";
  runtimeInputs = [ python3 ];
  text = ''
    exec python3 -m http.server "''${1:-8000}"
  '';
}
