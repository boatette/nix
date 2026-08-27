{
  flake.modules.nixos.libvirt =
    { config, pkgs, ... }:
    {
      virtualisation = {
        libvirtd = {
          enable = true;
          onBoot = "ignore";
          onShutdown = "shutdown";

          qemu = {
            runAsRoot = false;
            swtpm.enable = true;
            vhostUserPackages = [ pkgs.virtiofsd ];
          };
        };

        spiceUSBRedirection.enable = true;
      };
      programs.virt-manager.enable = true;

      users.extraGroups.libvirtd.members = [ config.constants.username ];

      systemd.tmpfiles.rules = [
        "d /var/lib/libvirt/qemu/networks/autostart 0755 root root -"
        "L+ /var/lib/libvirt/qemu/networks/autostart/default.xml - - - - ../default.xml"
      ];

      environment.systemPackages = with pkgs; [ quickemu ];
    };
}
