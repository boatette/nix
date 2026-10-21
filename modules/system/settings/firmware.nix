{
  flake.modules.nixos.firmware.services.fwupd = {
    enable = true;

    daemonSettings.IdleTimeout = 60;
  };
}
