{ inputs, lib, ... }:
{
  flake-file.inputs.monitor-autorotate = {
    url = "git+file:///home/boatette/Projects/monitor-autorotate";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # turns the monitors between the profiles in flake.monitors as the Pico on the arm reports
  flake.modules.nixos.monitor-autorotate =
    { config, pkgs, ... }:
    let
      inherit (inputs.self.lib) monitorProfiles transformName;

      profiles = monitorProfiles (inputs.self.monitors.${config.networking.hostName} or { });

      # one wlr-randr call, so the outputs turn together or not at all. they stay turned until
      # umbriel restarts, which starts them in the first profile again
      apply =
        monitors:
        lib.concatStringsSep " " (
          [ "wlr-randr" ]
          ++ lib.mapAttrsToList (
            name: m:
            "--output ${name} --transform ${transformName m} --pos ${toString m.position.x},${toString m.position.y}"
          ) monitors
        );

      rotate = pkgs.writeShellApplication {
        name = "umbriel-monitor-profile";
        runtimeInputs = [ pkgs.wlr-randr ];
        text = ''
          case "''${1-}" in
          ${lib.concatStrings (
            lib.mapAttrsToList (profile: monitors: ''
              ${profile})
              ${apply monitors};;
            '') profiles
          )}
          *)
            echo "no monitor profile ''${1-}" >&2
            exit 1
            ;;
          esac
        '';
      };
    in
    {
      imports = [ inputs.monitor-autorotate.nixosModules.default ];

      services.monitor-autorotate = {
        enable = true;
        command = lib.getExe rotate;
      };
    };
}
