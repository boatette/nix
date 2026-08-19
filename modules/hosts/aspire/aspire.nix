{ self, ... }:

{
  flake.modules.nixos.aspire = {
    imports = with self.modules.nixos; [
      base
      desktop

      backup
      gaming
      libvirt
    ];

    networking.hostName = "aspire";

    system.stateVersion = "26.05";
  };
}
