{
  writeShellApplication,
  gh,
  coreutils,
  findutils,
}:

writeShellApplication {
  name = "walls-push";
  meta.description = "publish packed wallpaper tarballs as a dated release";

  runtimeInputs = [
    gh
    coreutils
    findutils
  ];

  bashOptions = [ ];
  text = builtins.readFile ./walls-push.sh;
}
