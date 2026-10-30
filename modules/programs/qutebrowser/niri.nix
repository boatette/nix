{ inputs, ... }:
{
  flake.modules.homeManager.niri.wayland.windowManager.niri.settings._children = [
    (inputs.self.lib.niriWindowRule { app-id = "^org\\.qutebrowser\\.qutebrowser$"; } {
      default-column-width.proportion = 1.0;
    })
  ];
}
