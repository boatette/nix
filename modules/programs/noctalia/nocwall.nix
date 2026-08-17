{
  flake.modules.homeManager.desktop =
    { pkgs, config, ... }:
    let
      wallpapers = "${config.home.homeDirectory}/Pictures/Wallpapers";
      inbox = "${wallpapers}/Dynamic";
    in
    {
      systemd.user = {
        paths.nocwall-sort = {
          Install.WantedBy = [ "default.target" ];
          Path = {
            PathChanged = inbox;
            Unit = "nocwall-sort.service";
          };
          Unit.Description = "Watch the wallhaven download directory for new wallpapers";
        };

        services = {
          nocwall-sort = {
            Service = {
              ExecStart = "${pkgs.nocwall}/bin/nocwall apply --settle-secs 15";
              IOSchedulingClass = "idle";
              Nice = 10;
              Type = "oneshot";
            };
            Unit = {
              Description = "File newly downloaded wallpapers into their palette folders";
              StartLimitBurst = 5;
              StartLimitIntervalSec = 60;
            };
          };

          nocwall-tint-gc = {
            Service = {
              ExecStart = "${pkgs.nocwall}/bin/nocwall tint gc";
              IOSchedulingClass = "idle";
              Nice = 10;
              Type = "oneshot";
            };
            Unit.Description = "Evict stale recoloured wallpapers from the tint cache";
          };
        };

        timers = {
          nocwall-sort = {
            Install.WantedBy = [ "timers.target" ];
            Timer = {
              OnCalendar = "weekly";
              Persistent = true;
              RandomizedDelaySec = "1h";
            };
            Unit.Description = "Weekly sweep for unsorted wallpapers";
          };

          nocwall-tint-gc = {
            Install.WantedBy = [ "timers.target" ];
            Timer = {
              OnCalendar = "weekly";
              Persistent = true;
              RandomizedDelaySec = "1h";
            };
            Unit.Description = "Weekly tint cache eviction";
          };
        };
      };
    };
}
