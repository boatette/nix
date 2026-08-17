{
  writeShellApplication,
  walls-optimise,
  gnutar,
  zstd,
  coreutils,
}:

writeShellApplication {
  name = "walls-pack";
  meta.description = "build one release tarball per wallpaper theme";

  runtimeInputs = [
    walls-optimise
    gnutar
    zstd
    coreutils
  ];

  bashOptions = [ ];
  text = builtins.readFile ./walls-pack.sh;
}
