{
  flake.modules.homeManager.aion =
    { config, pkgs, ... }:
    let
      lock = "${config.programs.swaylock.package}/bin/swaylock -f";
      wlopm = "${pkgs.wlopm}/bin/wlopm";
    in
    {
      programs.swaylock = {
        enable = true;

        settings = {
          image = "${../../../assets/wallpaper.png}";
          scaling = "fill";
          show-failed-attempts = true;
          indicator-caps-lock = true;

          color = "191724";
          inside-color = "191724";
          inside-clear-color = "191724";
          inside-ver-color = "191724";
          inside-wrong-color = "191724";
          ring-color = "26233a";
          ring-clear-color = "9ccfd8";
          ring-ver-color = "c4a7e7";
          ring-wrong-color = "eb6f92";
          key-hl-color = "ebbcba";
          bs-hl-color = "eb6f92";
          line-color = "00000000";
          separator-color = "00000000";
          text-color = "e0def4";
          text-clear-color = "e0def4";
          text-ver-color = "e0def4";
          text-wrong-color = "eb6f92";
        };
      };

      services.swayidle = {
        enable = true;

        timeouts = [
          {
            timeout = 600;
            command = lock;
          }
          {
            timeout = 660;
            command = "${wlopm} --off '*'";
            resumeCommand = "${wlopm} --on '*'";
          }
          {
            timeout = 900;
            command = "${pkgs.systemd}/bin/systemctl suspend";
          }
        ];

        events = {
          before-sleep = lock;
          inherit lock;
        };
      };
    };
}
