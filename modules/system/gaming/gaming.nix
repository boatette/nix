{ inputs, ... }:
{
  flake.modules.nixos.gaming =
    { pkgs, ... }:
    {
      nixpkgs.overlays = [ inputs.millennium.overlays.default ];

      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        package = pkgs.millennium-steam;
      };

      programs.gamemode.enable = true;
    };

  flake.modules.homeManager.umbriel.programs.umbriel.settings.window_rule = [
    {
      match.app_id = "^steam$";
      default_maximize = true;
    }
    {
      match.app_id = "^steam$";
      match.title = "^notificationtoasts_\\d+_desktop$";
      default_position = {
        x = 10;
        y = 10;
        anchor = "bottom_right";
      };
      default_focused = false;
      default_pinned = true;
    }
  ];

  flake.modules.niri.niri.settings.window-rules = [
    {
      matches = [ { app-id = "steam"; } ];
      open-maximized = true;
    }
    {

      matches = [
        {
          app-id = "steam";
          title = ''^notificationtoasts_\d+_desktop$'';
        }
      ];
      default-floating-position = _: {
        props = {
          x = 10;
          y = 10;
          relative-to = "bottom-right";
        };
      };
      geometry-corner-radius = 0;
      border.off = _: { };
    }
  ];
}
