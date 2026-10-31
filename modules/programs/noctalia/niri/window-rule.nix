{ inputs, ... }:
{
  flake.modules.homeManager.niri.wayland.windowManager.niri.settings._children = [
    (inputs.self.lib.niriWindowRule { app-id = "^dev\\.noctalia\\.Noctalia$"; } {
      open-floating = true;
      default-column-width.fixed = 1080;
      default-window-height.fixed = 920;
      opacity = 1.0;
    })
  ];
}
