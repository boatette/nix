{
  flake.modules.nixos.aspire =
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
        };
        kernelModules = [ "kvm-intel" ];
        extraModulePackages = [ ];

        # recompute with `btrfs inspect-internal map-swapfile -r /.swapvol/swapfile` if swapfile is recreated
        resumeDevice = "/dev/disk/by-id/nvme-WD_PC_SN740_SDDQNQD-512G-1014_2309F9403437-part2";
        kernelParams = [ "resume_offset=32253184" ];
      };

      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

      services.power-profiles-daemon.enable = true;
    };
}
