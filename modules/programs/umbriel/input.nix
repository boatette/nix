{ inputs, ... }:
{
  flake.modules.homeManager.boatette =
    { config, ... }:
    {
      programs.umbriel.settings.input = {
        keyboard = inputs.self.constants.keyboard // {
          repeat_delay = 200;
          repeat_rate = 35;
        };

        touchpad.natural_scroll = true;

        cursor.theme = config.home.pointerCursor.name;
      };
    };
}
