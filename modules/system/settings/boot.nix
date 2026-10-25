{
  flake.modules.nixos.boot =
    { pkgs, ... }:
    {
      boot = {
        loader = {
          systemd-boot = {
            enable = true;

            configurationLimit = 5;
          };
          efi.canTouchEfiVariables = true;
          timeout = 0;
        };

        kernelPackages = pkgs.linuxPackages_latest;

        tmp.cleanOnBoot = true;
      };
    };
}
