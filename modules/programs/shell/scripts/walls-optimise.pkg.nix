{
  writeShellApplication,
  libwebp,
  ffmpeg,
  coreutils,
  findutils,
  gnused,
  gawk,
}:

writeShellApplication {
  name = "walls-optimise";
  meta.description = "recompress wallpapers to WebP for distribution";

  runtimeInputs = [
    libwebp
    ffmpeg
    coreutils
    findutils
    gnused
    gawk
  ];

  bashOptions = [ ];
  text = builtins.readFile ./walls-optimise.sh;
}
