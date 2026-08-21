{ lib, config, ... }:
{
  perSystem =
    { config, ... }:
    {
      checks = lib.mapAttrs' (name: lib.nameValuePair "package-${name}") config.packages;
    };

  flake.checks.x86_64-linux = lib.mapAttrs' (
    name: host: lib.nameValuePair "host-${name}" host.config.system.build.toplevel
  ) config.flake.nixosConfigurations;
}
