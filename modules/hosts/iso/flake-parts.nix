{ inputs, ... }:
{
  flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "iso";

  perSystem = _: {
    packages.iso = inputs.self.nixosConfigurations.iso.config.system.build.isoImage;
  };
}
