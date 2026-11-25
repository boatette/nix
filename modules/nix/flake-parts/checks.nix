{ inputs, lib, ... }:
let
  root = ../../..;

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
      # the iso compresses aspire's whole closure, and host-aspire already builds it
      checks =
        lib.mapAttrs' (name: lib.nameValuePair "package-${name}") (removeAttrs config.packages [ "iso" ])
        // {
          host-aspire = inputs.self.nixosConfigurations.aspire.config.system.build.toplevel;

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
}
