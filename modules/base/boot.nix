{
    flake.modules.nixos.base =
        { pkgs, ... }:
        {
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
