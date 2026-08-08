{ inputs, self, ... }:

{
    flake.nixosConfigurations.redux = inputs.nixpkgs.lib.nixosSystem {
        modules = [
            self.nixosModules.hostRedux
        ];
    };

    flake.nixosModules.hostRedux = {
        imports = [
            self.nixosModules.base
            self.nixosModules.desktop

            self.nixosModules.gaming
            self.nixosModules.virtualbox

            self.nixosModules.reduxHardware
        ];

        networking.hostName = "redux";

        boot.initrd.kernelModules = [ "i915" ];

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
