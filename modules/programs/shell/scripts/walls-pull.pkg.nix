{
  writeShellApplication,
  curl,
  gnutar,
  zstd,
  coreutils,
}:

writeShellApplication {
  name = "walls-pull";
  meta.description = "fetch wallpapers from the latest GitHub release";

  runtimeInputs = [
    curl
    gnutar
    zstd
    coreutils
  ];

  bashOptions = [ ];
  text = builtins.readFile ./walls-pull.sh;
}
