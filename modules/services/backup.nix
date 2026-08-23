{ inputs, ... }:
{
  flake.modules.nixos.backup.home-manager.sharedModules = [
    inputs.self.modules.homeManager.backup
  ];

  flake.modules.homeManager.backup =
    { pkgs, config, ... }:
    {
      home.packages = [ pkgs.local.ssd ];

      systemd.user = {
        services.ssd-backup = {
          Unit.Description = "Mirror home to the SSD";
          Service = {
            ExecStart = "${pkgs.local.ssd}/bin/ssd backup";
            Type = "oneshot";
            IOSchedulingClass = "idle";
            Nice = 10;
          };
        };

        services.ssd-restore = {
          Install.WantedBy = [ "default.target" ];
          Unit = {
            Description = "Restore home from the SSD";
            ConditionPathExists = "!${config.home.homeDirectory}/.local/state/ssd-restore.stamp";
          };
          Service = {
            ExecStart = "${pkgs.local.ssd}/bin/ssd restore";
            Type = "oneshot";
            IOSchedulingClass = "idle";
            Nice = 10;
          };
        };

        timers.ssd-backup = {
          Install.WantedBy = [ "timers.target" ];
          Unit.Description = "Daily SSD mirror";
          Timer = {
            OnCalendar = "daily";
            Persistent = true;
            RandomizedDelaySec = "30m";
          };
        };
      };
    };
}
