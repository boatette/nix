{ inputs, lib, ... }:
{
  flake-file.inputs.monitor-autorotate = {
    url = "git+file:///home/boatette/Projects/monitor-autorotate?ref=niri";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # turns the monitors between the profiles in flake.monitors as the Pico on the arm reports
  flake.modules.nixos.monitor-autorotate =
    { config, pkgs, ... }:
    let
      profiles = inputs.self.lib.monitorProfiles (
        inputs.self.monitors.${config.networking.hostName} or { }
      );

      # niri msg output turns an output until niri restarts, which starts it in the first profile again
      apply =
        name: m:
        let
          transform = if m.transform == 0 then "normal" else toString m.transform;
        in
        ''
          niri msg output ${name} transform ${transform}
          niri msg output ${name} position set ${toString m.position.x} ${toString m.position.y}
        '';

      rotate = pkgs.writeShellApplication {
        name = "niri-monitor-profile";
        runtimeInputs = [ config.programs.niri.package ];
        text = ''
          case $1 in
          ${lib.concatStrings (
            lib.mapAttrsToList (profile: monitors: ''
              ${profile})
              ${lib.concatStrings (lib.mapAttrsToList apply monitors)};;
            '') profiles
          )}
          *)
            echo "no monitor profile $1" >&2
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
