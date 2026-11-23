{ inputs, lib, ... }:
let
  # the current profile, written by umbriel-monitor-profile. in the runtime dir, so an umbriel restart
  # keeps the arm's profile and a new login starts in the first one
  profileFile = "umbriel-monitor-profile.toml";
in
{
  flake-file.inputs.monitor-autorotate = {
    url = "github:boatette/monitor-autorotate";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # turns the monitors between the profiles in flake.monitors as the Pico on the arm reports
  flake.modules.nixos.aspire =
    { pkgs, ... }:
    let
      inherit (inputs.self.lib) monitorProfiles transformName umbrielLayout;

      profiles = monitorProfiles;

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
          coreutils
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
              layout=${umbrielLayout pkgs profile monitors};;
            '') profiles
          )}
          *)
            echo "no monitor profile $profile" >&2
            exit 1
            ;;
          esac

          # renamed into place, so umbriel never reloads a half-written file. one file, so the outputs
          # turn together or not at all
          install -m 644 "$layout" "$XDG_RUNTIME_DIR/.${profileFile}"
          mv -f "$XDG_RUNTIME_DIR/.${profileFile}" "$XDG_RUNTIME_DIR/${profileFile}"
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
    };

  flake.modules.homeManager.boatette.programs.umbriel.settings = {
    # read after the start layout's include, so it wins. umbriel watches it and reloads when it changes
    include.optional.files = [ "$XDG_RUNTIME_DIR/${profileFile}" ];

    # TODO: drop once the Pico on the arm is reporting
    keybinds."Mod+Shift+P" = "spawn umbriel-monitor-profile next";
  };
}
