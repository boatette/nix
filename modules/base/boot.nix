{
    flake.modules.nixos.base =
        { config, pkgs, ... }:
        {
            systemd.services.plymouth-quit.serviceConfig.ExecStart = [
                ""
                "${config.boot.plymouth.package}/bin/plymouth quit --retain-splash"
            ];

            boot = {
                loader = {
                    systemd-boot.enable = true;
                    efi.canTouchEfiVariables = true;
                    timeout = 0;
                };

                kernelPackages = pkgs.linuxPackages_latest;

                plymouth.enable = true;

                initrd = {
                    systemd.enable = true;

                    verbose = false;
                };
                consoleLogLevel = 3;
                kernelParams = [
                    "quiet"
                    "udev.log_priority=3"
                    "rd.systemd.show_status=auto"
                ];
            };
        };
}
