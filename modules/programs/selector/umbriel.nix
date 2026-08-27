{
  flake.modules.homeManager.umbriel.programs.umbriel.settings.layer_rule = [
    {
      match.namespace = "^selector$";
      blur = true;
      blur_ignore_alpha = 0.05;
      blur_optimized = false;
    }
  ];
}
