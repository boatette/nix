{
  flake.modules.nixos.aspire =
    { modulesPath, ... }:
    {
      imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

      boot.initrd.availableKernelModules = [
        "nvme"
        "sd_mod"
        "thunderbolt"
        "usb_storage"
        "xhci_pci"
      ];

      hardware.cpu.intel.updateMicrocode = true;

      services = {
        fstrim.enable = true;
        power-profiles-daemon.enable = true;
        thermald.enable = true;

        smartd = {
          enable = true;
          autodetect = false;
          devices = [ { device = "/dev/nvme0"; } ];
        };
      };
    };
}
