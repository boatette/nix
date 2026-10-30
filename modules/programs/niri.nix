{ inputs, ... }:
{
  # nixpkgs' niri is 26.04; windows keeping their place on screen as they move between workspaces
  # is only in git
  flake-file.inputs.niri = {
    url = "github:niri-wm/niri";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # the session and portals come from nixpkgs' module; home-manager writes config.kdl from the
  # settings in niri/, and `niri validate` checks it at build time
  flake.modules.nixos.niri =
    { pkgs, ... }:
    {
      programs.niri = {
        enable = true;
        package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.default;
        # the gtk file chooser rather than nautilus
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
        # validate against the niri that runs; the system already has its units and portals
        package = osConfig.programs.niri.package;
        systemd.enable = false;
        portalPackage = null;

        settings = {
          prefer-no-csd = { };
          hotkey-overlay.skip-at-startup = { };
          screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
        };
      };

      home.packages = with pkgs; [
        wl-clipboard
        libnotify
        jq
      ];
    };
}
