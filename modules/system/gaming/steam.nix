{ inputs, ... }:
{
  flake-file.inputs.steam-config-nix = {
    url = "github:different-name/steam-config-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.steam =
    { lib, pkgs, ... }:
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
          };

          "753640" = {
            name = "Outer Wilds";
            compatTool = "proton_experimental";
          };

          "322170" = {
            name = "Geometry Dash";
            dllOverrides."xinput1_4" = "n,b";
            wrappers = [
              (lib.getExe pkgs.gamescope)
              "-W"
              "1920"
              "-H"
              "1080"
              "--"
            ];
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
