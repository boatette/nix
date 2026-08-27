{
  flake.modules.homeManager.umbriel.programs.umbriel.settings.window_rule = [
    {
      match.app_id = "^steam$";
      default_maximize = true;
    }
    {
      match.app_id = "^steam$";
      match.title = "^notificationtoasts_\\d+_desktop$";
      default_position = {
        x = 10;
        y = 10;
        anchor = "bottom_right";
      };
      default_focused = false;
      default_pinned = true;
    }
  ];
}
