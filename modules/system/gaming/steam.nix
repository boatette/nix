{ inputs, lib, ... }:
let
  primary = lib.head (
    lib.attrValues (lib.filterAttrs (_: m: m.primary or false) inputs.self.monitors)
  );

  mode = builtins.match "([0-9]+)x([0-9]+)@([0-9.]+)" primary.mode;

  width = builtins.elemAt mode 0;
  height = builtins.elemAt mode 1;
  refresh = toString (builtins.floor (builtins.fromJSON (builtins.elemAt mode 2)));

  nvidiaOffload = {
    __NV_PRIME_RENDER_OFFLOAD = 1;
    __NV_PRIME_RENDER_OFFLOAD_PROVIDER = "NVIDIA-G0";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __VK_LAYER_NV_optimus = "NVIDIA_only";
  };
in
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
            env = nvidiaOffload;
          };

          "753640" = {
            name = "Outer Wilds";
            compatTool = "proton_experimental";
            env = nvidiaOffload;
          };

          "322170" = {
            name = "Geometry Dash";
            dllOverrides."xinput1_4" = "n,b";
            wrappers = [
              (lib.getExe pkgs.gamescope)
              "-W"
              width
              "-H"
              height
              "-r"
              refresh
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
