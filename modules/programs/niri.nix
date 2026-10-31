{ inputs, ... }:
{
  flake-file.inputs.niri = {
    url = "github:niri-wm/niri";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.niri =
    { pkgs, ... }:
    {
      programs.niri = {
        enable = true;
        package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.default;
        useNautilus = false;
      };

      xdg.terminal-exec = {
        enable = true;
        settings.default = [ "foot.desktop" ];
      };
    };

  flake.modules.homeManager.niri =
    { osConfig, pkgs, ... }:
    {
      wayland.windowManager.niri = {
        enable = true;
        package = osConfig.programs.niri.package;
        systemd.enable = false;
        portalPackage = null;

        settings = {
          prefer-no-csd = { };
          hotkey-overlay.skip-at-startup = { };
        };
      };

      home.packages = with pkgs; [
        wl-clipboard
        libnotify
        jq
      ];
    };
}
