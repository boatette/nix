{
  flake.modules.homeManager.aion =
    { config, pkgs, ... }:
    let
      lock = "${config.programs.swaylock.package}/bin/swaylock -f";
      wlopm = "${pkgs.wlopm}/bin/wlopm";
      loginctl = "${pkgs.systemd}/bin/loginctl";

      inherit (config.constants) palette;
    in
    {
      programs.swaylock = {
        enable = true;

        settings = {
          image = "${../../../assets/wallpaper.png}";
          scaling = "fill";
          show-failed-attempts = true;
          indicator-caps-lock = true;

          color = palette.base;
          inside-color = palette.base;
          inside-clear-color = palette.base;
          inside-ver-color = palette.base;
          inside-wrong-color = palette.base;
          ring-color = palette.overlay;
          ring-clear-color = palette.foam;
          ring-ver-color = palette.iris;
          ring-wrong-color = palette.love;
          key-hl-color = palette.rose;
          bs-hl-color = palette.love;
          line-color = "00000000";
          separator-color = "00000000";
          text-color = palette.text;
          text-clear-color = palette.text;
          text-ver-color = palette.text;
          text-wrong-color = palette.love;
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
