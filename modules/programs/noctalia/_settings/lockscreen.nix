{
  lib,
  primaryMonitor,
  loginBoxes,
  ...
}:

{
  lockscreen = {
    allow_empty_password = false;
    blur_intensity = 0.5;
    blurred_desktop = false;
    enabled = true;
    fingerprint = true;
    lock_before_suspend = true;
    monitors = [ primaryMonitor ];
    tint_intensity = 0.3;
    wallpaper = "";
  };

  lockscreen_widgets = {
    enabled = true;
    schema_version = 2;
    widget_order = map (entry: entry.name) loginBoxes;

    grid = {
      cell_size = 16;
      major_interval = 4;
      visible = true;
    };

    widget = lib.listToAttrs loginBoxes;
  };
}
