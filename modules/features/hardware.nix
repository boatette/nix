{
    flake.modules.nixos.base =
        { pkgs, ... }:
        {
            hardware = {
                graphics = {
                    enable = true;
                    extraPackages = [ pkgs.intel-media-driver ];
                };

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
