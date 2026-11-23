{
  flake.modules.nixos.aspire.services.fwupd = {
    enable = true;

    daemonSettings.IdleTimeout = 60;
  };
}
