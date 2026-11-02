{
  flake.modules.homeManager.niri.wayland.windowManager.niri.settings._children = [
    {
      layer-rule = {
        match._props.namespace = "^noctalia-wallpaper";
        place-within-backdrop = true;
      };
    }

    {
      layer-rule = {
        match._props.namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|desktop-widget-.*)$";
        background-effect.xray = false;
      };
    }

    {
      layer-rule = {
        match._props.namespace = "^noctalia-window-switcher$";
        background-effect = {
          blur = true;
          xray = false;
        };
      };
    }
  ];
}
