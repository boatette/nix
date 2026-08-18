[
  {
    # matches = [ { namespace = "^noctalia-backdrop"; } ]; # requires backdrop.enabled = true in noctalia
    matches = [ { namespace = "^noctalia-wallpaper"; } ]; # requires backdrop.enabled = false in noctalia
    place-within-backdrop = true;
  }
  {
    matches = [ { namespace = "noctalia-window-switcher"; } ];
    background-effect = {
      blur = true;
      xray = false;
    };
  }
]
