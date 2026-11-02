{ inputs, ... }:
let
  rule = inputs.self.lib.niriWindowRule;
in
{
  flake.modules.homeManager.niri.wayland.windowManager.niri.settings._children = [
    (rule { app-id = "^steam(webhelper)?$"; } { open-floating = true; })
    (rule
      {
        app-id = "^steam$";
        title = "^Steam$";
      }
      {
        open-floating = false;
        default-column-width.proportion = 1.0;
      }
    )
    (rule
      {
        app-id = "^steam$";
        title = "^Steam Big Picture Mode$";
      }
      {
        open-floating = false;
        open-fullscreen = true;
      }
    )
    (rule
      {
        app-id = "^steam$";
        title = "^notificationtoasts_\\d+_desktop$";
      }
      {
        open-focused = false;
        default-floating-position._props = {
          x = 10;
          y = 10;
          relative-to = "bottom-right";
        };
      }
    )
  ];
}
