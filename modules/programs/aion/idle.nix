{
  flake.modules.homeManager.aion =
    { config, pkgs, ... }:
    let
      lock = "${config.programs.swaylock.package}/bin/swaylock -f";
      wlopm = "${pkgs.wlopm}/bin/wlopm";
      loginctl = "${pkgs.systemd}/bin/loginctl";
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

      services.hypridle = {
        enable = true;

        settings = {
          general = {
            lock_cmd = "${pkgs.procps}/bin/pidof swaylock || ${lock}";
            before_sleep_cmd = "${loginctl} lock-session";
          };

          listener = [
            {
              timeout = 600;
              on-timeout = "${loginctl} lock-session";
            }
            {
              timeout = 660;
              on-timeout = "${wlopm} --off '*'";
              on-resume = "${wlopm} --on '*'";
            }
            {
              timeout = 900;
              on-timeout = "${pkgs.systemd}/bin/systemctl suspend";
            }
          ];
        };
      };
    };
}
