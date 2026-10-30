{ inputs, ... }:
let
  rule = inputs.self.lib.niriWindowRule;
  fullWidth.default-column-width.proportion = 1.0;
in
{
  flake.modules.homeManager.niri.wayland.windowManager.niri.settings._children = [
    (rule { app-id = "vesktop|gimp|libreoffice"; } fullWidth)
    (rule { app-id = "stremio"; } { open-fullscreen = true; })
  ];
}
