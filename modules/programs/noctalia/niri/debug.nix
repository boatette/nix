{
  # lets noctalia's launcher and notifications focus the windows they open
  flake.modules.homeManager.niri.wayland.windowManager.niri.settings.debug.honor-xdg-activation-with-invalid-serial =
    { };
}
