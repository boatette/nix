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
      checks = lib.mapAttrs' (name: lib.nameValuePair "package-${name}") config.packages // {
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
