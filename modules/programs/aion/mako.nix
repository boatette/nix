{
  flake.modules.homeManager.aion =
    { config, ... }:
    let
      inherit (config.constants.fonts) sans;
    in
    {
      # dbus-activated, so it only starts once something sends a notification
      services.mako = {
        enable = true;

        settings = {
          font = "${sans.name} ${toString sans.size}";

          anchor = "top-right";
          margin = "10";
          width = 320;
          padding = "10";
          border-size = 1;
          border-radius = 0;
          default-timeout = 5000;

          background-color = "#191724";
          text-color = "#e0def4";
          border-color = "#ebbcba";
          progress-color = "over #26233a";

          "urgency=high" = {
            border-color = "#eb6f92";
            default-timeout = 0;
          };
        };
      };
    };
}
