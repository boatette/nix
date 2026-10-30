{
  # workspaces are see-through, so their shadows would outline empty boxes on the wallpaper
  flake.modules.homeManager.niri.wayland.windowManager.niri.settings.overview.workspace-shadow.off =
    { };
}
