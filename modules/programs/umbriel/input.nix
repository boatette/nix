{
  flake.modules.homeManager.umbriel =
    { config, ... }:
    {
      programs.umbriel.settings.input = {
        keyboard = config.constants.keyboard // {
          repeat_delay = 200;
          repeat_rate = 35;
        };

        touchpad.natural_scroll = true;

        cursor.theme = "capitaine-cursors";
      };
    };
}
