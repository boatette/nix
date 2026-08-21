{ lib, ... }:
{
  options.flake.monitors = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
    description = "Connected outputs, keyed by connector name";
    example = {
      "eDP-1" = {
        mode = "1920x1080@144";
        scale = 1.0;
        transform = 0;
        position = {
          x = 1920;
          y = 0;
        };
        primary = true;
      };
    };
  };
}
