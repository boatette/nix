{ inputs, ... }:
{
  flake.modules.nixos.backup.home-manager.sharedModules = [
    inputs.self.modules.homeManager.backup
  ];

  flake.modules.homeManager.backup =
    { config, pkgs, ... }:
    let
      environment = [
        "SSD_NOTIFY=1"
        "XDG_STATE_HOME=${config.xdg.stateHome}"
      ];
    in
    {
      home = {
        packages = [ pkgs.local.ssd ];

        shellAliases = {
          baknow = "systemctl --user start ssd-backup.service";
          bakstatus = "systemctl --user list-timers ssd-backup.timer";
          baklog = "journalctl --user -u ssd-backup -n 50 --no-pager";
        };
      };

      systemd.user = {
        services = {
          ssd-backup = {
            Unit.Description = "Mirror home to the SSD";
            Service = {
              ExecStart = "${pkgs.local.ssd}/bin/ssd backup";
              Type = "oneshot";
              Environment = environment;
              IOSchedulingClass = "idle";
              Nice = 10;
            };
          };

          ssd-restore = {
            Unit = {
              Description = "Restore home from the SSD";
              ConditionPathExists = "!${config.xdg.stateHome}/ssd-restore.stamp";
            };
            Service = {
              ExecStart = "${pkgs.local.ssd}/bin/ssd restore";
              Type = "oneshot";
              Environment = environment;
              IOSchedulingClass = "idle";
              Nice = 10;
            };
            Install.WantedBy = [ "default.target" ];
          };
        };

        timers.ssd-backup = {
          Unit.Description = "Daily SSD mirror";
          Timer = {
            OnCalendar = "daily";
            Persistent = true;
            RandomizedDelaySec = "30m";
          };
          Install.WantedBy = [ "timers.target" ];
        };
      };
    };
}
