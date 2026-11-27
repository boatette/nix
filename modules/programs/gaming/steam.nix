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
      inherit (inputs.self.constants) monitors;

      # gamescope runs games at the primary monitor's mode
      mode = builtins.match "([0-9]+)x([0-9]+)@([0-9]+)" monitors.modes.${monitors.primary};

      wrappers = [
        (lib.getExe pkgs.gamemode)
        (lib.getExe pkgs.gamescope)
        "-W"
        (lib.elemAt mode 0)
        "-H"
        (lib.elemAt mode 1)
        "-r"
        (lib.elemAt mode 2)
        "--"
        (lib.getExe' pkgs.coreutils "env")
      ]
      ++ lib.mapAttrsToList (name: value: "${name}=${value}") inputs.self.lib.nvidiaOffloadEnv;
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
            dllOverrides."xinput1_4" = "n,b";
            inherit wrappers;
          };
        };
      };
    };
}
