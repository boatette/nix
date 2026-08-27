{
  flake.modules.homeManager.umbriel.programs.umbriel.settings.window_rule = [
    {
      match.app_id = "^zen-beta$";
      default_maximize = true;
    }
  ];
}
