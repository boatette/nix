{
  flake.modules.homeManager.umbriel.programs.umbriel.settings.window_rule = [
    {
      match.app_id = "helium|vesktop|gimp|libreoffice";
      default_maximize = true;
    }
    {
      match.app_id = "stremio";
      default_fullscreen = true;
    }
  ];
}
