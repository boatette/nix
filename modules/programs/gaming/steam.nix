{ inputs, ... }:
{
  flake-file.inputs.steam-config-nix = {
    url = "github:different-name/steam-config-nix";
    inputs = {
      flake-parts.follows = "flake-parts";
      nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.homeManager.boatette =
    { lib, pkgs, ... }:
    let
      inherit (inputs.self.lib) nvidiaOffloadEnv parseMode primaryMonitor;

      # gamescope runs games at the primary monitor's mode
      mode = parseMode inputs.self.monitors.${primaryMonitor}.mode;

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
        (lib.getExe' pkgs.coreutils "env")
      ]
      ++ lib.mapAttrsToList (name: value: "${name}=${value}") nvidiaOffloadEnv;
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
}
