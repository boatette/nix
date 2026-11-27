{
  flake.modules.homeManager.boatette.programs.umbriel.settings.window_rule = [
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

    {
      match.app_id = "^(gamescope|steam_app_\\d+)$";
      default_fullscreen = true;
    }

    # java's app_id carries the version and bedrock's is the launcher's, but both titles start the same
    {
      match.title = "^Minecraft";
      default_fullscreen = true;
    }
  ];
}
