{ pkgs, ... }:
{
    hardware.graphics = {
        enable = true;
        extraPackages = [ pkgs.intel-media-driver ];
    };

    services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
    };
    security.rtkit.enable = true;

    hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
    };

    services.power-profiles-daemon.enable = true;
}
