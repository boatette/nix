{ inputs, self, ... }:

{
  flake.nixosConfigurations.aspire = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.modules.nixos.hostAspire
    ];
  };

  flake.modules.nixos.hostAspire =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        self.modules.nixos.base
        self.modules.nixos.desktop

        self.modules.nixos.gaming
        self.modules.nixos.virtualbox

        self.modules.nixos.aspireHardware
      ];

      networking.hostName = "aspire";

      boot.initrd.kernelModules = [ "i915" ];
      hardware.graphics.extraPackages = [ pkgs.intel-media-driver ];

      services.xserver.videoDrivers = [ "nvidia" ];

      hardware.nvidia = {
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

      boot.initrd.luks.devices."luks-2462d0d4-9733-413c-a67c-cdca469be2c7".allowDiscards = true;

      fileSystems."/mnt/storage" = {
        device = "/dev/disk/by-uuid/e59f23dd-5e74-46b9-92bf-386ec2fa9c27"; # not partuuid
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
