{ inputs, ... }:
{
  flake.modules.nixos.backup.home-manager.sharedModules = [
    inputs.self.modules.homeManager.backup
  ];

  flake.modules.homeManager.backup =
    { pkgs, config, ... }:
    let
      environment = [
        "SSD_NOTIFY=1"
        "XDG_STATE_HOME=${config.xdg.stateHome}"
      ];
    in
    {
      home.packages = [ pkgs.local.ssd ];

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
            Install.WantedBy = [ "default.target" ];
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
