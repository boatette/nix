{ self, ... }:

{
  flake.modules.nixos.aspire = {
    imports = with self.modules.nixos; [
      base
      desktop

      backup
      gaming
      virtualbox
    ];

    networking.hostName = "aspire";

    system.stateVersion = "26.05";
  };
}
