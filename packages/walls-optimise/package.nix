{
  writeShellApplication,
  libwebp,
  ffmpeg,
  coreutils,
  findutils,
  gnused,
  gawk,
  gnugrep,
}:
writeShellApplication {
  name = "walls-optimise";
  meta.description = "recompress wallpapers to WebP";

  runtimeInputs = [
    libwebp
    ffmpeg
    coreutils
    findutils
    gnused
    gawk
    gnugrep
  ];

  bashOptions = [ ];
  text = builtins.readFile ./walls-optimise.sh;
}
