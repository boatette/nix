{ inputs, ... }:
{
  flake.modules.nixos.iso-full = {
    imports = [ inputs.self.modules.nixos.iso ];

    isoImage.storeContents = [
      inputs.self.nixosConfigurations.aspire.config.system.build.toplevel
    ];
  };
}
