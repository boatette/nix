{ inputs, ... }:
let
  rule = inputs.self.lib.niriWindowRule;
in
{
  flake.modules.homeManager.niri.wayland.windowManager.niri.settings._children = [
    (rule {
      app-id = "^steam$";
      title = "^Steam$";
    } { default-column-width.proportion = 1.0; })
    (rule {
      app-id = "^steam$";
      title = "^Steam Big Picture Mode$";
    } { open-fullscreen = true; })
  ];
}
