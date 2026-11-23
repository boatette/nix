{ config, lib, ... }:
let
  inherit (lib) mkOption types;
  inherit (config.flake) monitors;

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

  profile = types.submodule {
    options = {
      transform = mkOption {
        type = types.nullOr transform;
        default = null;
        description = "Rotation in this profile, or null for the monitor's own";
      };

      position = mkOption {
        type = types.nullOr (types.submodule { options = position; });
        default = null;
        description = "Position in this profile, or null for the monitor's own";
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
        description = "Variations monitor-autorotate switches every monitor between, starting in the first by name";
      };

      primary = mkOption {
        type = types.bool;
        default = false;
        description = "The output games size themselves to, and the greeter and noctalia's lockscreen and desktop widgets go on";
      };
    };
  };

  parseMode =
    mode:
    let
      parts = builtins.match "([0-9]+)x([0-9]+)(@([0-9.]+))?" mode;
    in
    {
      width = lib.elemAt parts 0;
      height = lib.elemAt parts 1;
      refresh = lib.elemAt parts 3;
    };

  isPortrait =
    m:
    lib.elem m.transform [
      90
      270
      "flipped-90"
      "flipped-270"
    ];

  # xwayland misplaces clients at negative coordinates, so every layout is shifted to start at 0,0
  shifted =
    ms:
    let
      min = axis: lib.foldl' lib.min 0 (lib.mapAttrsToList (_: m: m.position.${axis}) ms);
    in
    lib.mapAttrs (
      _: m:
      m
      // {
        position = {
          x = m.position.x - min "x";
          y = m.position.y - min "y";
        };
      }
    ) ms;

  profileNames = lib.sort lib.lessThan (
    lib.unique (lib.concatMap (m: lib.attrNames m.profiles) (lib.attrValues monitors))
  );

  monitorProfiles =
    if profileNames == [ ] then
      { default = shifted monitors; }
    else
      lib.genAttrs profileNames (
        p:
        shifted (
          lib.mapAttrs (_: m: m // lib.filterAttrs (_: v: v != null) (m.profiles.${p} or { })) monitors
        )
      );

  logicalSize =
    m:
    let
      mode = parseMode m.mode;
      width = lib.toInt mode.width * 1.0 / m.scale;
      height = lib.toInt mode.height * 1.0 / m.scale;
    in
    if isPortrait m then
      {
        width = height;
        height = width;
      }
    else
      { inherit width height; };

  transformName = m: if m.transform == 0 then "normal" else toString m.transform;

  startLayout = monitorProfiles.${lib.head (lib.attrNames monitorProfiles)};
in
{
  options.flake.monitors = mkOption {
    type = types.attrsOf monitor;
    default = { };
    description = "Connected outputs, keyed by connector name";
  };

  config.flake.lib = {
    inherit
      isPortrait
      logicalSize
      monitorProfiles
      parseMode
      startLayout
      transformName
      ;

    primaryMonitor = lib.findFirst (
      name: monitors.${name}.primary
    ) (throw "no monitor in flake.monitors is `primary`") (lib.attrNames monitors);

    # umbriel runs a portrait output's strip top to bottom when its workspaces sit side by side
    umbrielLayout =
      pkgs: name: layout:
      (pkgs.formats.toml { }).generate "umbriel-${name}.toml" {
        output = lib.mapAttrs (_: m: {
          transform = transformName m;
          position = [
            m.position.x
            m.position.y
          ];
          workspace_axis = if isPortrait m then "horizontal" else "vertical";
        }) layout;
      };

    # a widget laid out for 1920x1080, scaled onto the output; other placement_* sizes land in noctalia's state
    noctaliaWidget =
      output:
      { box, ... }@widget:
      let
        size = logicalSize startLayout.${output};
        x = n: n * size.width / 1920.0;
        y = n: n * size.height / 1080.0;
      in
      removeAttrs widget [ "box" ]
      // {
        inherit output;

        placement_width = size.width;
        placement_height = size.height;

        cx = x box.cx;
        cy = y box.cy;
      }
      // lib.optionalAttrs (box ? width) {
        box_width = x box.width;
        box_height = y box.height;
      };
  };
}
