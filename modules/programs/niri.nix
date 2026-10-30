{
  # niri itself, its session and portals come from nixpkgs; home-manager writes config.kdl from
  # the settings in niri/, and `niri validate` checks it at build time
  flake.modules.nixos.niri = {
    programs.niri = {
      enable = true;
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
