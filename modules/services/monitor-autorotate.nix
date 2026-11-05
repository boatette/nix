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
      profiles = inputs.self.lib.monitorProfiles (
        inputs.self.monitors.${config.networking.hostName} or { }
      );

      transform = m: if m.transform == 0 then "normal" else toString m.transform;

      # both turn an output until the compositor restarts, which starts it in the first profile again
      niri = name: m: ''
        niri msg output ${name} transform ${transform m}
        niri msg output ${name} position set ${toString m.position.x} ${toString m.position.y}
      '';

      wlr = name: m: ''
        wlr-randr --output ${name} --transform ${transform m} --pos ${toString m.position.x},${toString m.position.y}
      '';

      cases =
        desktop: apply:
        lib.concatStrings (
          lib.mapAttrsToList (profile: monitors: ''
            ${desktop}:${profile})
            ${lib.concatStrings (lib.mapAttrsToList apply monitors)};;
          '') profiles
        );

      rotate = pkgs.writeShellApplication {
        name = "monitor-profile";
        runtimeInputs = [
          config.programs.niri.package
          pkgs.wlr-randr
        ];
        # each session overwrites XDG_CURRENT_DESKTOP, where NIRI_SOCKET could be left behind
        text = ''
          case ''${XDG_CURRENT_DESKTOP:-}:$1 in
          ${cases "niri" niri}
          ${cases "*" wlr}
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
