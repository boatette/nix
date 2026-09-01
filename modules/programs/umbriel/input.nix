{
  flake.modules.homeManager.umbriel =
    { config, ... }:
    {
      programs.umbriel.settings.input = {
        inherit (config.constants) keyboard;

        touchpad.natural_scroll = true;

        cursor.theme = "capitaine-cursors";
      };
    };
}
