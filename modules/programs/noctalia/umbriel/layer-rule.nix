{
  flake.modules.homeManager.umbriel.programs.umbriel.settings.layer_rule = [
    {
      match.namespace = "^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd|desktop-widget-[^\"]*)$";
      blur = true;
      # the optimized blur only samples the wallpaper, which fringes rounded corners and
      # leaves windows behind the dock unblurred
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
