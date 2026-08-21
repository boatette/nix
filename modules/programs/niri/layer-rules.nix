{
  flake.modules.niri.niri.settings.layer-rules = [
    {
      matches = [ { namespace = "^noctalia-wallpaper"; } ];

      place-within-backdrop = true;
    }
    {
      matches = [ { namespace = "noctalia-window-switcher"; } ];
      background-effect = {
        blur = true;
        xray = false;
      };
    }
  ];
}
