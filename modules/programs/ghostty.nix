{

  flake.modules.homeManager.ghostty.programs.ghostty = {
    enable = true;

    settings = {
      theme = "noctalia";

      font-family = "JetBrainsMono Nerd Font";
      font-size = 12;

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
}
