{
  flake.modules.homeManager.umbriel.programs.umbriel.settings.window_rule = [
    {
      match.app_id = "^dev\\.noctalia\\.luciole$";
      opacity = 1.0;
    }

    {
      match = {
        app_id = "^dev\\.noctalia\\.luciole$";
        # main windows are always titled Luciole, and pickers take the title the requesting app gives them
        title = "^(?!Luciole$)";
      };
      default_floating = true;
    }
  ];
}
