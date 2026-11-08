{
  flake.modules.nixos.aspire =
    { modulesPath, ... }:
    {
      imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "nvme"
        "usb_storage"
        "sd_mod"
      ];

      hardware.nvidia = {
        open = true;

        powerManagement = {
          enable = true;
          finegrained = true;
        };

        prime = {
          offload = {
            enable = true;
            enableOffloadCmd = true;
          };

          intelBusId = "PCI:0:2:0";
          nvidiaBusId = "PCI:1:0:0";
        };
      };

      services = {
        power-profiles-daemon.enable = true;
        xserver.videoDrivers = [ "nvidia" ];

        smartd = {
          autodetect = false;
          devices = [ { device = "/dev/nvme0"; } ];
        };
      };
    };
}
