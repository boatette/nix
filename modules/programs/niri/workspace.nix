{ lib, ... }:
{
  flake.modules.homeManager.niri.wayland.windowManager.niri.settings._children = map (n: {
    workspace._args = [ (toString n) ];
  }) (lib.range 1 4);
}
