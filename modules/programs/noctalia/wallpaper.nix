{
  flake.modules.homeManager.noctalia.programs.noctalia.settings = {
    wallpaper = {
      enabled = true;
      fill_mode = "crop";
      fill_color = "";
      edge_smoothness = 0.3;

      directory = "";
      directory_dark = "";
      directory_light = "";
      per_monitor_directories = false;

      transition = [
        "fade"
        "wipe"
        "disc"
        "stripes"
        "zoom"
        "honeycomb"
      ];
      transition_duration = 1500.0;
      transition_on_startup = false;

      automation = {
        enabled = false;
        interval_seconds = 1800;
        order = "random";
        recursive = true;
      };
    };

    weather = {
      enabled = true;
      effects = true;
      refresh_minutes = 30;
      unit = "metric";
    };

    location = {
      auto_locate = true;
      address = "";
      custom_schedule = false;
      sunrise = "";
      sunset = "";
    };

    calendar = {
      enabled = true;
      refresh_minutes = 15;

      account.personal_google = {
        name = "Personal Calendar";
        type = "google";
      };
    };

    nightlight = {
      enabled = false;
      force = false;
      temperature_day = 6500;
      temperature_night = 4000;
    };

    config = { };
  };
}
