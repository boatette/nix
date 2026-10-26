{ inputs, ... }:
{
  flake-file.inputs.steam-config-nix = {
    url = "github:different-name/steam-config-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.steam =
    {
      lib,
      osConfig,
      pkgs,
      ...
    }:
    let
      host = osConfig.networking.hostName;
      monitors = inputs.self.monitors.${host} or { };
      offload = osConfig.hardware.nvidia.prime.offload.enable or false;

      primary =
        lib.findFirst (m: m.primary)
          (throw "gaming/steam.nix: mark a monitor in flake.monitors.${host} primary")
          (lib.attrValues monitors);

      # gamescope runs games at the primary monitor's mode
      mode =
        if primary.mode != null && lib.hasInfix "@" primary.mode then
          inputs.self.lib.parseMode primary.mode
        else
          throw "gaming/steam.nix: the primary monitor on ${host} needs a mode with a refresh rate, like 1920x1080@144";

      wrappers = [
        (lib.getExe pkgs.gamemode)
        (lib.getExe pkgs.gamescope)
        "-W"
        mode.width
        "-H"
        mode.height
        "-r"
        (toString (builtins.floor (builtins.fromJSON mode.refresh)))
        "--"
      ]
      ++ lib.optionals offload (
        [ (lib.getExe' pkgs.coreutils "env") ]
        ++ lib.mapAttrsToList (name: value: "${name}=${value}") inputs.self.lib.nvidiaOffloadEnv
      );
    in
    {
      imports = [ inputs.steam-config-nix.homeModules.default ];

      programs.steam.config = {
        enable = true;
        onSteamRunning = "close";

        desktopEntries.enable = true;

        apps = {
          "252950" = {
            name = "Rocket League";
            compatTool = "proton_experimental";
            inherit wrappers;
          };

          "753640" = {
            name = "Outer Wilds";
            compatTool = "proton_experimental";
            inherit wrappers;
          };

          "322170" = {
            name = "Geometry Dash";
            # FIX: reenable on geode update
            # dllOverrides."xinput1_4" = "n,b";
            inherit wrappers;
          };
        };
      };
    };

  flake.modules.nixos.gaming =
    { config, ... }:
    {
      home-manager.users.${config.constants.username}.imports = [
        inputs.self.modules.homeManager.steam
      ];
    };
}
