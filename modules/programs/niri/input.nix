{
  flake.modules.homeManager.niri =
    { config, ... }:
    {
      wayland.windowManager.niri.settings = {
        input = {
          keyboard = {
            xkb = config.constants.keyboard;
            repeat-delay = 200;
            repeat-rate = 35;
          };

          touchpad = {
            tap = { };
            drag-lock = { };
            dwt = { };
            natural-scroll = { };
          };
        };

        cursor = {
          xcursor-theme = config.home.pointerCursor.name;
          xcursor-size = config.home.pointerCursor.size;
        };
      };
    };
}
