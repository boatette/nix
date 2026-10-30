{
  flake.modules.homeManager.niri =
    { config, ... }:
    {
      wayland.windowManager.niri.settings = {
        input = {
          keyboard = {
            xkb = {
              inherit (config.constants.keyboard) layout options;
            };
            repeat-delay = 200;
            repeat-rate = 35;
          };

          touchpad = {
            tap = { };
            drag-lock = { };
            dwt = { };
            natural-scroll = { };
            scroll-method = "two-finger";
            click-method = "button-areas";
          };
        };

        cursor = {
          xcursor-theme = config.home.pointerCursor.name;
          xcursor-size = config.home.pointerCursor.size;
        };
      };
    };
}
