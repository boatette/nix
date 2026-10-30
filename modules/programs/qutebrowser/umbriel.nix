{
  flake.modules.homeManager.umbriel.programs.umbriel.settings.window_rule = [
    {
      match.app_id = "^org\\.qutebrowser\\.qutebrowser$";
      default_maximize = true;
    }
  ];
}
