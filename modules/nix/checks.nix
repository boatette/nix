{ config, lib, ... }:

{
  perSystem =
    { config, ... }:
    {
      checks = lib.mapAttrs' (name: lib.nameValuePair "package-${name}") config.packages;
    };

  flake.checks.x86_64-linux.host-aspire =
    config.flake.nixosConfigurations.aspire.config.system.build.toplevel;
}
