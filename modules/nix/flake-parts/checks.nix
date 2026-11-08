{ config, lib, ... }:
let
  inherit (config.flake) nixosConfigurations;

  root = ../../..;

  # packages and hosts left out of flake checks, as they are slow to build
  unchecked = [
    "iso"
    "nvim-full"
  ];

  nixFiles = lib.fileset.toSource {
    inherit root;
    fileset = lib.fileset.fileFilter (file: file.hasExt "nix") root;
  };

  # treefmt skips what no formatter claims, so the formatting check can take the whole tree
  treeFiles = lib.fileset.toSource {
    inherit root;
    fileset = root;
  };
in
{
  perSystem =
    { config, pkgs, ... }:
    {
      checks =
        lib.mapAttrs' (name: lib.nameValuePair "package-${name}") (
          lib.removeAttrs config.packages unchecked
        )
        // {
          # nothing builds nvim-full, so at least make sure it still evaluates
          eval-nvim-full = pkgs.writeText "nvim-full.drv-path" (
            builtins.unsafeDiscardOutputDependency config.packages.nvim-full.drvPath
          );

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
      lib.optionalAttrs (!lib.elem name unchecked) {
        ${host.config.nixpkgs.hostPlatform.system}."host-${name}" = host.config.system.build.toplevel;
      }
    )
  ) { } nixosConfigurations;
}
