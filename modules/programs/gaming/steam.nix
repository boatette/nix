{ inputs, ... }:
{
  flake-file.inputs.steam-config-nix = {
    url = "github:different-name/steam-config-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.steam =
    {
      lib,
      pkgs,
      osConfig,
      ...
    }:
    let
      host = osConfig.networking.hostName;
      monitors = inputs.self.monitors.${host} or { };
      offload = osConfig.hardware.nvidia.prime.offload.enable or false;

      primary = lib.findFirst (m: m.primary or false) null (lib.attrValues monitors);

      primaryMode =
        lib.throwIf (primary == null)
          "gaming/steam.nix: no monitor in flake.monitors.${host} is marked `primary = true`"
          (primary.mode or null);

      matched =
        lib.throwIf (primaryMode == null)
          "gaming/steam.nix: the primary monitor on ${host} has no `mode`; gamescope needs one"
          (builtins.match "([0-9]+)x([0-9]+)@([0-9.]+)" primaryMode);

      parsed = lib.throwIf (
        matched == null
      ) "gaming/steam.nix: monitor mode must be WxH@R, got: ${primaryMode}" matched;

      width = builtins.elemAt parsed 0;
      height = builtins.elemAt parsed 1;
      refresh = toString (builtins.floor (builtins.fromJSON (builtins.elemAt parsed 2)));

      wrappers = [
        (lib.getExe pkgs.gamemode)
        (lib.getExe pkgs.gamescope)
        "-W"
        width
        "-H"
        height
        "-r"
        refresh
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
