{ lib, config, ... }:
{
  perSystem =
    { config, ... }:
    {
      checks = lib.mapAttrs' (name: lib.nameValuePair "package-${name}") config.packages;
    };

  flake.checks = lib.foldlAttrs (
    acc: name: host:
    lib.recursiveUpdate acc {
      ${host.config.nixpkgs.hostPlatform.system}."host-${name}" = host.config.system.build.toplevel;
    }
  ) { } config.flake.nixosConfigurations;
}
