{ config, lib, ... }:
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
        description = "Variations monitor-autorotate switches every monitor between, starting in the first by name";
      };

      primary = mkOption {
        type = types.bool;
        default = false;
        description = "The output games size themselves to, and the greeter and noctalia's lockscreen and desktop widgets go on";
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

  config.flake.lib =
    let
      # "1920x1080@75.000" -> { width = "1920"; height = "1080"; refresh = "75.000"; }, with a null refresh when it has none
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

      # each profile's layout, from the first by name, or one `default` layout when no monitor has any;
      # positions are shifted until none is negative, as xwayland misplaces clients there
      monitorProfiles =
        monitors:
        let
          profiles = lib.sort lib.lessThan (
            lib.unique (lib.concatMap (m: lib.attrNames m.profiles) (lib.attrValues monitors))
          );

          # a monitor with a profile's changes applied
          inProfile = profile: m: m // lib.filterAttrs (_: v: v != null) (m.profiles.${profile} or { });

          shifted =
            ms:
            let
              minX = lib.foldl' lib.min 0 (lib.mapAttrsToList (_: m: m.position.x) ms);
              minY = lib.foldl' lib.min 0 (lib.mapAttrsToList (_: m: m.position.y) ms);
            in
            lib.mapAttrs (
              _: m:
              m
              // {
                position = {
                  x = m.position.x - minX;
                  y = m.position.y - minY;
                };
              }
            ) ms;
        in
        if profiles == [ ] then
          { default = shifted monitors; }
        else
          lib.genAttrs profiles (p: shifted (lib.mapAttrs (_: inProfile p) monitors));

      isPortrait =
        m:
        lib.elem m.transform [
          90
          270
          "flipped-90"
          "flipped-270"
        ];

      # the transform as wlr-randr and umbriel name it
      transformName = m: if m.transform == 0 then "normal" else toString m.transform;

      # the size an output takes up in the layout, after rotation and scale
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

      # the layout a host's compositor starts in, its first profile; monitor-autorotate turns away from there
      startLayout =
        host:
        let
          profiles = monitorProfiles (config.flake.monitors.${host} or { });
        in
        profiles.${lib.head (lib.attrNames profiles)};

      # the name of a host's primary output
      primaryMonitor =
        host:
        let
          monitors = config.flake.monitors.${host} or { };
        in
        lib.findFirst (name: monitors.${name}.primary)
          (throw "no monitor in flake.monitors.${host} is marked `primary = true`")
          (lib.attrNames monitors);

      # a noctalia lockscreen or desktop widget on one of a host's outputs, its box laid out for a
      # 1920x1080 screen and scaled onto the output. noctalia copies the whole section into its state
      # file, shadowing this, when placement_* is not the output's logical size
      noctaliaWidget =
        host: output:
        { box, ... }@widget:
        let
          size = logicalSize (startLayout host).${output};
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
    in
    {
      inherit
        parseMode
        monitorProfiles
        isPortrait
        transformName
        logicalSize
        startLayout
        primaryMonitor
        noctaliaWidget
        ;
    };
}
