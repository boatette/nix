{ lib, ... }:
{
  # named workspaces persist when empty; they take the first indices, so Mod+1..3 still reach them
  flake.modules.homeManager.niri.wayland.windowManager.niri.settings._children = map (n: {
    workspace._args = [ (toString n) ];
  }) (lib.range 1 3);
}
