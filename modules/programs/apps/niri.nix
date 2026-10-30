{ inputs, ... }:
let
  rule = inputs.self.lib.niriWindowRule;
  fullWidth.default-column-width.proportion = 1.0;
in
{
  flake.modules.homeManager.niri.wayland.windowManager.niri.settings._children = [
    (rule { app-id = "vesktop|gimp|libreoffice"; } fullWidth)
    (rule { app-id = "^io\\.bassi\\.Amberol$"; } {
      open-floating = true;
      default-floating-position._props = {
        x = 0;
        y = 40;
        relative-to = "top";
      };
    })
    (rule { app-id = "stremio"; } { open-fullscreen = true; })
  ];
}
