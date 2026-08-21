{
  writeShellApplication,
  gh,
  curl,
  coreutils,
  findutils,
}:
writeShellApplication {
  name = "walls-push";
  meta.description = "upload wallpaper tarballs";

  runtimeInputs = [
    gh
    curl
    coreutils
    findutils
  ];

  bashOptions = [ ];
  text = builtins.readFile ./walls-push.sh;
}
