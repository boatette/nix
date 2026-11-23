{
  flake.modules.homeManager.boatette.programs.umbriel.settings.window_rule = [
    {
      match.app_id = "^(com\\.github\\.PintaProject\\.Pinta|libreoffice.*)$";
      default_maximize = true;
    }

    {
      match.app_id = "^com\\.stremio\\.Stremio$";
      default_fullscreen = true;
    }
  ];
}
