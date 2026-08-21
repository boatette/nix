{
  writeShellApplication,
  libwebp,
  ffmpeg,
  imagemagick,
  gh,
  curl,
  gnutar,
  zstd,
  coreutils,
  findutils,
  gnused,
  gawk,
  gnugrep,
}:
writeShellApplication {
  name = "walls";
  meta.description = "optimise, pack, publish and prune wallpapers";

  runtimeInputs = [
    libwebp
    ffmpeg
    imagemagick
    gh
    curl
    gnutar
    zstd
    coreutils
    findutils
    gnused
    gawk
    gnugrep
  ];

  bashOptions = [ ];
  text = builtins.readFile ./walls.sh;
}
