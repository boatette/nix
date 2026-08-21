{
  flake.monitors = {
    "eDP-1" = {
      mode = "1920x1080@144";
      primary = true;
    };

    "HDMI-A-1" = {
      mode = "1920x1080@75.000";
      position.x = -1920;
    };
  };
}
