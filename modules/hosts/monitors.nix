{ lib, ... }:
let
  inherit (lib) mkOption types;

  transform = types.enum [
    0
    90
    180
    270
    "flipped"
    "flipped-90"
    "flipped-180"
    "flipped-270"
  ];

  position = {
    x = mkOption {
      type = types.int;
      default = 0;
      description = "Left edge in the output layout";
    };

    y = mkOption {
      type = types.int;
      default = 0;
      description = "Top edge in the output layout";
    };
  };

  # what a profile changes about a monitor; null keeps the monitor's own setting
  profile = types.submodule {
    options = {
      transform = mkOption {
        type = types.nullOr transform;
        default = null;
        description = "Rotation in this profile";
      };

      position = mkOption {
        type = types.nullOr (types.submodule { options = position; });
        default = null;
        description = "Position in this profile";
      };
    };
  };

  monitor = types.submodule {
    options = {
      mode = mkOption {
        type = types.nullOr (types.strMatching "[0-9]+x[0-9]+(@[0-9.]+)?");
        default = null;
        example = "1920x1080@144";
        description = "Resolution and optional refresh rate as WIDTHxHEIGHT[@HZ]; null keeps the preferred mode";
      };

      scale = mkOption {
        type = types.number;
        default = 1;
        description = "Output scale";
      };

      transform = mkOption {
        type = transform;
        default = 0;
        description = "Rotation in degrees, optionally flipped";
      };

      inherit position;

      profiles = mkOption {
        type = types.attrsOf profile;
        default = { };
        example = {
          landscape = { };
          portrait = {
            transform = 90;
            position = {
              x = -1080;
              y = -420;
            };
          };
        };
        description = "Variations aion switches every monitor between with `aion msg profile`, starting in the first by name";
      };

      primary = mkOption {
        type = types.bool;
        default = false;
        description = "Whether games size themselves to this output";
      };
    };
  };
in
{
  options.flake.monitors = mkOption {
    type = types.attrsOf (types.attrsOf monitor);
    default = { };
    description = "Connected outputs per host, keyed by hostname then connector name";
    example = {
      aspire."eDP-1" = {
        mode = "1920x1080@144";
        primary = true;
      };
    };
  };

  # "1920x1080@75.000" -> { width = "1920"; height = "1080"; refresh = "75.000"; }, with a null refresh when it has none
  config.flake.lib.parseMode =
    mode:
    let
      parts = builtins.match "([0-9]+)x([0-9]+)(@([0-9.]+))?" mode;
    in
    {
      width = lib.elemAt parts 0;
      height = lib.elemAt parts 1;
      refresh = lib.elemAt parts 3;
    };
}
