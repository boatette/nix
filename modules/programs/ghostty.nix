{
  flake.modules.homeManager.ghostty =
    { config, ... }:
    let
      inherit (config.constants.fonts) mono;
    in
    {
      programs.ghostty = {
        enable = true;

        settings = {
          theme = "noctalia";

          font-family = mono.name;
          font-size = mono.size;

          window-padding-x = 14;
          window-padding-y = 14;
          window-decoration = "none";

          background-opacity = 0.5;

          confirm-close-surface = false;
          gtk-single-instance = true;
          quit-after-last-window-closed = false;

          window-inherit-working-directory = false;
        };
      };

      xdg.configFile."systemd/user/graphical-session.target.wants/app-com.mitchellh.ghostty.service".source =
        "${config.programs.ghostty.package}/share/systemd/user/app-com.mitchellh.ghostty.service";
    };
}
