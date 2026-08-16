{
  flake.modules.nixos.aspire.fileSystems."/mnt/storage" = {
    device = "/dev/disk/by-id/usb-Samsung_PSSD_T7_Shield_S6SKNS0WA05132K-0:0-part1";
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
}
