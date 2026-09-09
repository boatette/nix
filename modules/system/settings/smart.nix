{
  flake.modules.nixos.smart.services.smartd = {
    enable = true;

    autodetect = false;
    devices = [ { device = "/dev/nvme0"; } ];
  };
}
