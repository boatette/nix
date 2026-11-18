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

      # each profile as wlr-randr --json reports it, to tell which one the outputs are in
      layouts = builtins.toJSON (
        lib.mapAttrs (
          _:
          lib.mapAttrs (
            _: m: {
              transform = transformName m;
              inherit (m) position;
            }
          )
        ) profiles
      );

      rotate = pkgs.writeShellApplication {
        name = "umbriel-monitor-profile";
        runtimeInputs = with pkgs; [
          jq
          wlr-randr
        ];
        text = ''
          profile=''${1-}

          # the profile after the current one, for turning by hand until the arm reports
          if [ "$profile" = next ]; then
            names=(${lib.escapeShellArgs (lib.attrNames profiles)})
            current=$(wlr-randr --json | jq -r --argjson layouts ${lib.escapeShellArg layouts} '
              (map({ key: .name, value: { transform, position } }) | from_entries) as $now
              | $layouts | to_entries
              | map(select(.value | to_entries | all(.value == $now[.key])))
              | first.key // ""
            ')

            profile=''${names[0]}
            for i in "''${!names[@]}"; do
              if [ "''${names[$i]}" = "$current" ]; then
                profile=''${names[$(((i + 1) % ''${#names[@]}))]}
              fi
            done
          fi

          case "$profile" in
          ${lib.concatStrings (
            lib.mapAttrsToList (profile: monitors: ''
              ${profile})
              ${apply monitors};;
            '') profiles
          )}
          *)
            echo "no monitor profile $profile" >&2
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

      environment.systemPackages = [ rotate ];

      home-manager.sharedModules = [ inputs.self.modules.homeManager.monitor-autorotate ];
    };

  # TODO: drop once the Pico on the arm is reporting
  flake.modules.homeManager.monitor-autorotate.programs.umbriel.settings.keybinds."Mod+Shift+P" =
    "spawn umbriel-monitor-profile next";
}
