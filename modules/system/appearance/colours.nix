{ config, lib, ... }:
let
  inherit (config.flake.constants) palette roles;

  # a palette or role name as rrggbb
  raw = name: palette.${roles.${name} or name};

  channels =
    name:
    map (i: lib.fromHexString (builtins.substring i 2 (raw name))) [
      0
      2
      4
    ];

  byte = n: lib.fixedWidthString 2 "0" (lib.toLower (lib.toHexString n));

  alphaHex = opacity: byte (builtins.floor (opacity * 255 + 0.5));
in
{
  flake.lib.colours = {
    inherit alphaHex;

    hex = name: "#${raw name}";

    alpha = name: opacity: "#${raw name}${alphaHex opacity}";

    # a laid over b at opacity t, truncated as noctalia blends its containers
    mix =
      a: b: t:
      "#"
      + lib.concatStrings (
        lib.zipListsWith (x: y: byte (builtins.floor (x * t + y * (1 - t)))) (channels a) (channels b)
      );

    rgb = name: lib.concatMapStringsSep ", " toString (channels name);
  };
}
