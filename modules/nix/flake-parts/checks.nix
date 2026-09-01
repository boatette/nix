{ lib, config, ... }:
let
  inherit (config.flake) nixosConfigurations;

  root = ../../..;

  isoPackages = [ "iso" ];

  nixFiles = lib.fileset.toSource {
    inherit root;
    fileset = lib.fileset.fileFilter (file: file.hasExt "nix") root;
  };

  treeFiles = lib.fileset.toSource {
    inherit root;
    fileset = lib.fileset.unions [
      (lib.fileset.fileFilter (file: file.hasExt "nix" || file.hasExt "lua") root)
      (root + "/.stylua.toml")
    ];
  };
in
{
  perSystem =
    { config, pkgs, ... }:
    {
      checks =
        lib.mapAttrs' (name: lib.nameValuePair "package-${name}") (
          lib.removeAttrs config.packages isoPackages
        )
        // {
          deadnix = pkgs.runCommandLocal "check-deadnix" { } ''
            ${lib.getExe pkgs.deadnix} --fail ${nixFiles} && touch $out
          '';

          statix = pkgs.runCommandLocal "check-statix" { } ''
            ${lib.getExe pkgs.statix} check ${nixFiles} && touch $out
          '';

          formatting = pkgs.runCommandLocal "check-formatting" { } ''
            cp -r --no-preserve=mode ${treeFiles} tree
            cd tree
            ${lib.getExe config.formatter} --ci
            touch $out
          '';
        };
    };

  flake.checks = lib.foldlAttrs (
    acc: name: host:
    lib.recursiveUpdate acc (
      lib.optionalAttrs (!lib.elem name isoPackages) {
        ${host.config.nixpkgs.hostPlatform.system}."host-${name}" = host.config.system.build.toplevel;
      }
    )
  ) { } nixosConfigurations;
}
