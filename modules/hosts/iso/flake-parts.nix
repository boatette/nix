{ inputs, ... }:
{
  flake.nixosConfigurations =
    inputs.self.lib.mkNixos "x86_64-linux" "iso" // inputs.self.lib.mkNixos "x86_64-linux" "iso-full";

  perSystem = _: {
    packages = {
      iso = inputs.self.nixosConfigurations.iso.config.system.build.isoImage;
      iso-full = inputs.self.nixosConfigurations.iso-full.config.system.build.isoImage;
    };
  };
}
