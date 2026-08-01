{ config, scripts, ... }:
{
    systemd = {
        user = {
            services = {
                ssd-backup = {
                    Service = {
                        ExecStart = "${scripts.ssd-backup}/bin/ssd-backup";
                        IOSchedulingClass = "idle";
                        Nice = 10;
                        Type = "oneshot";
                    };
                    Unit = {
                        Description = "Mirror home data to the external SSD";
                    };
                };
                ssd-restore = {
                    Install = {
                        WantedBy = [ "default.target" ];
                    };
                    Service = {
                        ExecStart = "${scripts.ssd-restore}/bin/ssd-restore";
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
            timers = {
                ssd-backup = {
                    Install = {
                        WantedBy = [ "timers.target" ];
                    };
                    Timer = {
                        OnCalendar = "daily";
                        Persistent = true;
                        RandomizedDelaySec = "30m";
                    };
                    Unit = {
                        Description = "Daily mirror of home data to the external SSD";
                    };
                };
            };
        };
    };
}
