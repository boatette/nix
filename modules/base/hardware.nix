{
  flake.modules.nixos.base = {
    hardware = {
      graphics.enable = true;

      bluetooth = {
        enable = true;
        powerOnBoot = true;
      };
    };

    services = {
      pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };

      power-profiles-daemon.enable = true;
    };

    security.rtkit.enable = true;

    zramSwap.enable = true;
  };
}
