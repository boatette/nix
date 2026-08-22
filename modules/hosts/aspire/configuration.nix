{ inputs, ... }:
{
  flake.modules.nixos.aspire =
    { config, ... }:
    {
      imports = with inputs.self.modules.nixos; [
        desktop

        umbriel-session

        backup
        gaming
        libvirt

        boatette
      ];

      networking.hostName = "aspire";
      system.stateVersion = config.constants.stateVersion;
    };
}
