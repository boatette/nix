{ inputs, ... }:

{
  flake.modules.nixos.aspireHardware = {
    imports = [ inputs.disko.nixosModules.disko ];

    disko.devices.disk.main = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-WD_PC_SN740_SDDQNQD-512G-1014_2309F9403437";

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
}
