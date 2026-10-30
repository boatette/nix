{
  flake.modules.homeManager.niri.wayland.windowManager.niri.settings._children = [
    # the wallpaper stays put behind the workspaces in the overview
    {
      layer-rule._children = [
        { match._props.namespace = "^noctalia-wallpaper"; }
        { place-within-backdrop = true; }
      ];
    }
    # noctalia drops the dock's blur when it auto-hides, but niri keeps drawing it;
    # the dock is opaque anyway
    {
      layer-rule._children = [
        { match._props.namespace = "^noctalia-dock$"; }
        { background-effect.blur = false; }
      ];
    }
  ];
}
