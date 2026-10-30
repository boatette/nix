{
  flake.modules.homeManager.umbriel.programs.umbriel.settings.window_rule = [
    {
      match.app_id = "^dev\\.noctalia\\.Noctalia$";
      default_floating = true;
      default_floating_size_px = {
        width = 1080;
        height = 920;
      };
    }

    {
      match.app_id = "^dev\\.noctalia\\.UmbrielSharePicker$";
      default_floating = true;
      default_floating_size_px = {
        width = 800;
        height = 600;
      };
    }
  ];
}
