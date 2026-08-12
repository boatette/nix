{
    flake.modules.nixos.aspireHardware =
        {
            config,
            lib,
            modulesPath,
            ...
        }:

        {
            imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

            boot = {
                initrd = {
                    availableKernelModules = [
                        "xhci_pci"
                        "thunderbolt"
                        "nvme"
                        "usb_storage"
                        "sd_mod"
                    ];
                    kernelModules = [ ];
                    luks.devices."luks-2462d0d4-9733-413c-a67c-cdca469be2c7".device =
                        "/dev/disk/by-uuid/2462d0d4-9733-413c-a67c-cdca469be2c7";
                };
                kernelModules = [ "kvm-intel" ];
                extraModulePackages = [ ];
            };

            fileSystems = {
                "/" = {
                    device = "/dev/mapper/luks-2462d0d4-9733-413c-a67c-cdca469be2c7";
                    fsType = "btrfs";
                };

                "/home" = {
                    device = "/dev/mapper/luks-2462d0d4-9733-413c-a67c-cdca469be2c7";
                    fsType = "btrfs";
                    options = [ "subvol=home" ];
                };

                "/nix" = {
                    device = "/dev/mapper/luks-2462d0d4-9733-413c-a67c-cdca469be2c7";
                    fsType = "btrfs";
                    options = [ "subvol=nix" ];
                };

                "/boot" = {
                    device = "/dev/disk/by-uuid/4865-78C7";
                    fsType = "vfat";
                    options = [
                        "fmask=0077"
                        "dmask=0077"
                    ];
                };
            };

            nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
            hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
        };
}
