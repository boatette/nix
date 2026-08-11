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
                kernelModules = [ "kvm-intel" ];
                extraModulePackages = [ ];
            };

            fileSystems = {
                "/" = {
                    device = "/dev/disk/by-uuid/d8191e1a-7791-488b-8a7a-77dddee1b7e1";
                    fsType = "btrfs";
                };

                "/home" = {
                    device = "/dev/disk/by-uuid/d8191e1a-7791-488b-8a7a-77dddee1b7e1";
                    fsType = "btrfs";
                    options = [ "subvol=home" ];
                };

                "/nix" = {
                    device = "/dev/disk/by-uuid/d8191e1a-7791-488b-8a7a-77dddee1b7e1";
                    fsType = "btrfs";
                    options = [ "subvol=nix" ];
                };

                "/boot" = {
                    device = "/dev/disk/by-uuid/93F9-01EF";
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
