{
  flake.modules.niri.niri.settings.input = {
    keyboard.xkb = {
      layout = "us,us";
      variant = ",dvp";
      options = "caps:super,grp:win_space_toggle";
    };

    touchpad = {
      tap = _: { };
      natural-scroll = _: { };
    };
  };
}
