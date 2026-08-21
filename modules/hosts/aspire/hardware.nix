{
  flake.modules.nixos.aspire =
    {
      config,
      lib,
      modulesPath,
      pkgs,
      ...
    }:
    {
      imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

      boot = {
        initrd.availableKernelModules = [
          "xhci_pci"
          "thunderbolt"
          "nvme"
          "usb_storage"
          "sd_mod"
        ];

        initrd.kernelModules = [ "i915" ];
        kernelModules = [ "kvm-intel" ];
        extraModulePackages = [ ];

        resumeDevice = "/dev/disk/by-id/nvme-WD_PC_SN740_SDDQNQD-512G-1014_2309F9403437-part2";

        kernelParams = [ "resume_offset=32253184" ];
      };

      hardware = {
        cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
        graphics.extraPackages = [ pkgs.intel-media-driver ];

        nvidia = {
          open = true;
          modesetting.enable = true;
          package = config.boot.kernelPackages.nvidiaPackages.stable;

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
      };

      services = {
        power-profiles-daemon.enable = true;
        xserver.videoDrivers = [ "nvidia" ];

        fprintd.package = pkgs.fprintd.override {
          libfprint = pkgs.local.libfprint-elan-press;
        };
      };

      environment.sessionVariables = {
        LIBVA_DRIVER_NAME = "iHD";
        VDPAU_DRIVER = "va_gl";
      };
    };
}
