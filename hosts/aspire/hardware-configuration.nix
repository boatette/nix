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
                initrd.availableKernelModules = [
                    "xhci_pci"
                    "thunderbolt"
                    "nvme"
                    "uas"
                    "usb_storage"
                    "sd_mod"
                ];
                initrd.kernelModules = [ ];
                kernelModules = [ "kvm-intel" ];
                extraModulePackages = [ ];
            };

            fileSystems = {
                "/" = {
                    device = "/dev/disk/by-uuid/e78a042b-9725-4f1c-9f8a-3acfd03d3f2b";
                    fsType = "btrfs";
                };

                "/home" = {
                    device = "/dev/disk/by-uuid/e78a042b-9725-4f1c-9f8a-3acfd03d3f2b";
                    fsType = "btrfs";
                    options = [ "subvol=home" ];
                };

                "/nix" = {
                    device = "/dev/disk/by-uuid/e78a042b-9725-4f1c-9f8a-3acfd03d3f2b";
                    fsType = "btrfs";
                    options = [ "subvol=nix" ];
                };

                "/boot" = {
                    device = "/dev/disk/by-uuid/7F78-6C51";
                    fsType = "vfat";
                    options = [
                        "fmask=0077"
                        "dmask=0077"
                    ];
                };
            };

            swapDevices = [ ];

            nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
            hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
        };
}
