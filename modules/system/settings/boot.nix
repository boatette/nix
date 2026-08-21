{
  flake.modules.nixos.boot =
    { pkgs, ... }:
    {
      boot = {
        loader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
          timeout = 0;
        };

        kernelPackages = pkgs.linuxPackages_latest;
        initrd.systemd.enable = true;
      };
    };
}
