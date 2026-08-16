{
  lib,
  primaryMonitor,
  loginBoxes,
  ...
}:

{
  lockscreen.monitors = [ primaryMonitor ];

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
