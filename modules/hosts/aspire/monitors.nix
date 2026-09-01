{
  flake.monitors.aspire = {
    "eDP-1" = {
      mode = "1920x1080@144";
      primary = true;
    };

    "HDMI-A-1" = {
      mode = "1920x1080@75.000";
      # landscape
      # position.x = -1920;

      # portrait
      transform = 90;

      position = {
        x = -1080;
        y = -420;
      };
    };
  };
}
