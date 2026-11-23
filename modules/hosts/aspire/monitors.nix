{
  # eDP-1 is always there; HDMI-A-1, on a swivel arm to its left, comes and goes
  flake.constants.monitors = {
    primary = "eDP-1";
    arm = "HDMI-A-1";

    modes = {
      "eDP-1" = "1920x1080@144";
      "HDMI-A-1" = "1920x1080@75.000";
    };

    # the arm's two positions as wlr-randr reports them, with nothing at negative coordinates, where
    # xwayland misplaces clients; umbriel starts in landscape and monitor-autorotate switches
    layouts = {
      landscape = {
        "HDMI-A-1" = {
          transform = "normal";
          position = {
            x = 0;
            y = 0;
          };
        };
        "eDP-1" = {
          transform = "normal";
          position = {
            x = 1920;
            y = 0;
          };
        };
      };

      portrait = {
        "HDMI-A-1" = {
          transform = "90";
          position = {
            x = 0;
            y = 0;
          };
        };
        "eDP-1" = {
          transform = "normal";
          position = {
            x = 1080;
            y = 420;
          };
        };
      };
    };
  };
}
