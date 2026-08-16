{
  writeShellApplication,
  wallust,
  jq,
  imagemagick,
  coreutils,
}:

writeShellApplication {
  name = "wallust-palette";
  meta.description = "Derive a noctalia palette from a wallpaper via wallust";

  runtimeInputs = [
    wallust
    jq
    imagemagick
    coreutils
  ];

  runtimeEnv = {
    WALLUST_BASE = "${./wallust/base.toml}";
    WALLUST_TEMPLATE = "${./wallust/dump.json}";
    WALLUST_MAP = "${./wallust/palette.jq}";
  };

  bashOptions = [ ];
  text = builtins.readFile ./wallust-palette.sh;
}
