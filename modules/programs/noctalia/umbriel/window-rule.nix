{
  flake.modules.homeManager.umbriel.programs.umbriel.settings.window_rule = [
    {
      match.app_id = "^dev\\.noctalia\\.Noctalia$";
      default_floating = true;
      default_size = [
        1080
        920
      ];
    }

    {
      match.app_id = "^dev\\.noctalia\\.UmbrielSharePicker$";
      default_floating = true;
      default_size = [
        800
        600
      ];
    }
  ];
}
