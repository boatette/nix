{ inputs, self, ... }:

{
    flake.nixosConfigurations.redux = inputs.nixpkgs.lib.nixosSystem {
        modules = [
            self.nixosModules.hostRedux
        ];
    };

    flake.nixosModules.hostRedux =
        { pkgs, ... }:
        {
            imports = [
                self.nixosModules.base
                self.nixosModules.desktop

                self.nixosModules.gaming
                self.nixosModules.virtualbox

                self.nixosModules.reduxHardware
            ];

            networking.hostName = "redux";

            boot.initrd.kernelModules = [ "i915" ];
            hardware.graphics.extraPackages = [ pkgs.intel-media-driver ];

            preferences.monitors = {
                "eDP-1" = {
                    mode = "1920x1080@144";
                    primary = true;
                };

                "HDMI-A-1" = {
                    mode = "1920x1080@75.000";
                    position.x = -1920;
                };
            };

            programs.noctalia-greeter.settings.output = {
                name = "eDP-1";
                scale = 1;
            };

            fileSystems."/mnt/storage" = {
                device = "/dev/disk/by-uuid/95b03c14-a7be-4645-9573-5434f2024610";
                fsType = "ext4";
                options = [
                    "nofail"
                    "noatime"
                    "x-systemd.automount"
                    "x-systemd.device-timeout=5s"
                    "x-systemd.mount-timeout=5s"
                    "x-gvfs-show"
                ];
            };

            system.stateVersion = "26.05";
        };
}
