{
  flake.modules.nixos.desktop = {
    hardware = {
      graphics.enable = true;

      bluetooth = {
        enable = true;
        powerOnBoot = true;
      };
    };

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    security.rtkit.enable = true;
  };
}
