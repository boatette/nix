{
  flake.modules.homeManager.niri.wayland.windowManager.niri.settings._children = [
    # the wallpaper stays put behind the workspaces as they switch and in the overview
    {
      layer-rule._children = [
        { match._props.namespace = "^noctalia-wallpaper"; }
        { place-within-backdrop = true; }
      ];
    }

    # noctalia asks for blur on these itself; xray only samples the wallpaper, which fringes
    # rounded corners and leaves windows behind the dock unblurred
    {
      layer-rule._children = [
        {
          match._props.namespace = "^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd|desktop-widget-[^\"]*)$";
        }
        { background-effect.xray = false; }
      ];
    }

    {
      layer-rule._children = [
        { match._props.namespace = "^noctalia-window-switcher$"; }
        {
          background-effect = {
            blur = true;
            xray = false;
          };
        }
      ];
    }
  ];
}
