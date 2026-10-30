{
  # the wallpaper stays put behind the workspaces in the overview
  flake.modules.homeManager.niri.wayland.windowManager.niri.settings._children = [
    {
      layer-rule._children = [
        { match._props.namespace = "^noctalia-wallpaper"; }
        { place-within-backdrop = true; }
      ];
    }
  ];
}
