{
  flake.modules.nixos.plymouth =
    { config, ... }:
    {
      boot = {
        plymouth.enable = true;

        initrd.verbose = false;
        consoleLogLevel = 3;
        kernelParams = [
          "quiet"
          "udev.log_priority=3"
          "rd.systemd.show_status=auto"
        ];
      };

      systemd.services.plymouth-quit.serviceConfig.ExecStart = [
        ""
        "${config.boot.plymouth.package}/bin/plymouth quit --retain-splash"
      ];
    };
}
