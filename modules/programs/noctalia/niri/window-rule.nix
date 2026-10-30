{ inputs, ... }:
{
  flake.modules.homeManager.niri.wayland.windowManager.niri.settings._children = [
    (inputs.self.lib.niriWindowRule { app-id = "^dev\\.noctalia\\.Noctalia$"; } {
      open-floating = true;
      default-column-width.fixed = 1080;
      default-window-height.fixed = 920;
      # draws its own translucent background; window opacity would fade it a second time
      opacity = 1.0;
    })
  ];
}
