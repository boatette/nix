{
  flake.modules.homeManager.boatette.programs.umbriel.settings.layer_rule = [
    {
      match.namespace = "^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd|desktop-widget-[^\"]*)$";
      blur = true;
      # the optimized blur samples only the wallpaper, fringing rounded corners
      blur_optimized = false;
      blur_ignore_alpha = 0.05;
      blur_popups = true;
    }

    {
      match.namespace = "^noctalia-window-switcher$";
      blur = true;
      blur_optimized = false;
      blur_ignore_alpha = 0.05;
    }
  ];
}
