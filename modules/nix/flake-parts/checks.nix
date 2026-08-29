{ lib, config, ... }:
let
  inherit (config.flake) nixosConfigurations;

  root = ../../..;

  nixFiles = lib.fileset.toSource {
    inherit root;
    fileset = lib.fileset.fileFilter (file: file.hasExt "nix") root;
  };
in
{
  perSystem =
    { config, pkgs, ... }:
    {
      checks =
        lib.mapAttrs' (name: lib.nameValuePair "package-${name}") (
          lib.removeAttrs config.packages [
            "iso"
            "iso-full"
          ]
        )
        // {
          deadnix = pkgs.runCommandLocal "check-deadnix" { } ''
            ${lib.getExe pkgs.deadnix} --fail ${nixFiles} && touch $out
          '';

          statix = pkgs.runCommandLocal "check-statix" { } ''
            ${lib.getExe pkgs.statix} check ${nixFiles} && touch $out
          '';
        };
    };

  flake.checks = lib.foldlAttrs (
    acc: name: host:
    lib.recursiveUpdate acc {
      ${host.config.nixpkgs.hostPlatform.system}."host-${name}" = host.config.system.build.toplevel;
    }
  ) { } nixosConfigurations;
}
