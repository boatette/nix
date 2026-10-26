{
  flake.modules.homeManager.aion =
    { config, ... }:
    let
      inherit (config.constants) palette;
      inherit (config.constants.fonts) sans;
    in
    {
      # dbus-activated, so it only starts once something sends a notification
      services.mako = {
        enable = true;

        settings = {
          font = "${sans.name} ${toString sans.size}";

          # aion stacks fullscreen clients above the top layer
          layer = "overlay";
          anchor = "top-right";
          margin = "10";
          width = 320;
          padding = "10";
          border-size = 1;
          border-radius = 0;
          default-timeout = 5000;

          background-color = "#${palette.base}";
          text-color = "#${palette.text}";
          border-color = "#${palette.rose}";
          progress-color = "over #${palette.overlay}";

          "urgency=high" = {
            border-color = "#${palette.love}";
            default-timeout = 0;
          };
        };
      };
    };
}
