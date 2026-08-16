{
  flake.modules.homeManager.backup =
    { pkgs, config, ... }:
    {
      home.packages = with pkgs; [
        ssd-backup
        ssd-restore
      ];

      systemd.user = {
        services = {
          ssd-backup = {
            Service = {
              ExecStart = "${pkgs.ssd-backup}/bin/ssd-backup";
              IOSchedulingClass = "idle";
              Nice = 10;
              Type = "oneshot";
            };
            Unit.Description = "Mirror home data to the external SSD";
          };

          ssd-restore = {
            Install.WantedBy = [ "default.target" ];
            Service = {
              ExecStart = "${pkgs.ssd-restore}/bin/ssd-restore";
              IOSchedulingClass = "idle";
              Nice = 10;
              Type = "oneshot";
            };
            Unit = {
              ConditionPathExists = "!${config.home.homeDirectory}/.local/state/ssd-restore.stamp";
              Description = "Restore home data from the external SSD on a fresh install";
            };
          };
        };

        timers.ssd-backup = {
          Install.WantedBy = [ "timers.target" ];
          Timer = {
            OnCalendar = "daily";
            Persistent = true;
            RandomizedDelaySec = "30m";
          };
          Unit.Description = "Daily mirror of home data to the external SSD";
        };
      };
    };
}
