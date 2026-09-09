{
  flake.modules.homeManager.umbriel.programs.umbriel.settings.layer_rule = [
    {
      match.namespace = "^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd|desktop-widget-[^\"]*)$";
      blur = true;
      blur_ignore_alpha = 0.5;
      blur_popups = true;
    }

    {
      match.namespace = "^noctalia-window-switcher$";
      blur = true;
      blur_ignore_alpha = 0.5;
    }
  ];
}
