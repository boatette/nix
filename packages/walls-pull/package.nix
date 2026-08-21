{
  writeShellApplication,
  curl,
  gnutar,
  zstd,
  coreutils,
}:
writeShellApplication {
  name = "walls-pull";
  meta.description = "fetch wallpapers from GitHub";

  runtimeInputs = [
    curl
    gnutar
    zstd
    coreutils
  ];

  bashOptions = [ ];
  text = builtins.readFile ./walls-pull.sh;
}
