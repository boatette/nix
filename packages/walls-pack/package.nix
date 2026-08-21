{
  writeShellApplication,
  walls-optimise,
  gnutar,
  zstd,
  coreutils,
}:
writeShellApplication {
  name = "walls-pack";
  meta.description = "tar wallpapers per theme";

  runtimeInputs = [
    walls-optimise
    gnutar
    zstd
    coreutils
  ];

  bashOptions = [ ];
  text = builtins.readFile ./walls-pack.sh;
}
