{
  flake.modules.homeManager.umbriel.programs.umbriel.settings.window_rule = [
    {
      match.app_id = "^steam(webhelper)?$";
      default_floating = true;
    }

    {
      match = {
        app_id = "^steam$";
        title = "^Steam$";
      };
      default_floating = false;
      default_maximize = true;
    }

    {
      match = {
        app_id = "^steam$";
        title = "^Steam Big Picture Mode$";
      };
      default_floating = false;
      default_fullscreen = true;
    }

    {
      match = {
        app_id = "^steam$";
        title = "^notificationtoasts_\\d+_desktop$";
      };
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
