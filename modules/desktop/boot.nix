{
  flake.modules.nixos.desktop =
    { config, ... }:
    {
      systemd.services.plymouth-quit.serviceConfig.ExecStart = [
        ""
        "${config.boot.plymouth.package}/bin/plymouth quit --retain-splash"
      ];

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
    };
}
