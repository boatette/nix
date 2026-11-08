{
  flake.modules.homeManager.umbriel.programs.umbriel.settings.window_rule = [
    {
      match.app_id = "^vesktop$";
      default_maximize = true;
    }
  ];
}
