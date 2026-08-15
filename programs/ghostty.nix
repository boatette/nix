{
  flake.modules.homeManager.desktop =
    { config, ... }:
    {
      programs.ghostty = {
        enable = true;

        settings = {
          theme = "noctalia";

          font-family = "JetBrainsMono Nerd Font";
          font-size = 12;

          window-padding-x = 14;
          window-padding-y = 14;
          window-decoration = "none";

          background-opacity = 0.8;
          background-blur = true;

          confirm-close-surface = false;
          gtk-single-instance = true;
          quit-after-last-window-closed = false;
        };
      };

      xdg.configFile."systemd/user/graphical-session.target.wants/app-com.mitchellh.ghostty.service".source =
        "${config.programs.ghostty.package}/share/systemd/user/app-com.mitchellh.ghostty.service";
    };
}
