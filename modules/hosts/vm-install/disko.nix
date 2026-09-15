{ inputs, ... }:
{
  flake.modules.nixos.vm-install = {
    imports = [ inputs.disko.nixosModules.disko ];

    disko.devices.disk.main = {
      type = "disk";
      device = "/dev/disk/by-id/virtio-install-test";

      content = {
        type = "gpt";

        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "fmask=0077"
                "dmask=0077"
              ];
            };
          };

          root = {
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              settings.allowDiscards = true;

              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];

                subvolumes =
                  let
                    subvol = mountpoint: {
                      inherit mountpoint;
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                  in
                  {
                    "root" = subvol "/";
                    "home" = subvol "/home";
                    "nix" = subvol "/nix";
                  };
              };
            };
          };
        };
      };
    };
  };
}
