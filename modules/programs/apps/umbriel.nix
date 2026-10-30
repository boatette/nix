{
  flake.modules.homeManager.umbriel.programs.umbriel.settings.window_rule = [
    {
      match.app_id = "vesktop|gimp|libreoffice";
      default_maximize = true;
    }
    {
      match.app_id = "^io\\.bassi\\.Amberol$";
      default_floating = true;
      default_scratchpad = "default";
      default_focused = true;
      default_position = {
        x = 0;
        y = 40;
        anchor = "top";
      };
    }
    {
      match.app_id = "stremio";
      default_fullscreen = true;
    }
  ];
}
