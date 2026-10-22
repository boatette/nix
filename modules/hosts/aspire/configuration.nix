{ inputs, ... }:
{
  flake.modules.nixos.aspire =
    { config, ... }:
    {
      imports = with inputs.self.modules.nixos; [
        desktop

        backup
        gaming
        impermanence
        secure-boot

        boatette
      ];

      networking.hostName = "aspire";
      system.stateVersion = config.constants.stateVersion;
    };
}
