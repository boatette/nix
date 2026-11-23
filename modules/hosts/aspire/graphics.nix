{
  flake.modules.nixos.aspire =
    { pkgs, ... }:
    {
      boot.initrd.kernelModules = [ "i915" ];

      hardware = {
        graphics = {
          extraPackages = with pkgs; [
            intel-media-driver
            libvdpau-va-gl
            vpl-gpu-rt
          ];
          extraPackages32 = [ pkgs.driversi686Linux.intel-media-driver ];
        };

        nvidia = {
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
      };

      services.xserver.videoDrivers = [ "nvidia" ];

      environment.sessionVariables = {
        LIBVA_DRIVER_NAME = "iHD";
        VDPAU_DRIVER = "va_gl";
      };
    };
}
