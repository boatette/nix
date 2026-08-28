{ lib, config, ... }:
let
  inherit (config.flake) nixosConfigurations;
in
{
  perSystem =
    { config, ... }:
    {
      checks = lib.mapAttrs' (name: lib.nameValuePair "package-${name}") (
        lib.removeAttrs config.packages [
          "iso"
          "iso-full"
        ]
      );
    };

  flake.checks = lib.foldlAttrs (
    acc: name: host:
    lib.recursiveUpdate acc {
      ${host.config.nixpkgs.hostPlatform.system}."host-${name}" = host.config.system.build.toplevel;
    }
  ) { } nixosConfigurations;
}
