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
        llm
        monitor-autorotate
        petal
        printing
        secure-boot
        tailscale

        boatette
      ];

      networking.hostName = "aspire";
      system.stateVersion = config.constants.stateVersion;
    };
}
