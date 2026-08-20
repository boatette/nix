{ inputs, lib, ... }:

let
  tree = inputs.import-tree.addPath ./..;

  byName =
    suffix:
    lib.listToAttrs (
      map (file: lib.nameValuePair (lib.removeSuffix suffix (baseNameOf file)) file) (
        (tree.filter (lib.hasSuffix suffix)).files
      )
    );

  singles = byName ".pkg.nix";
  groups = byName ".pkgs.nix";

  overlay =
    final: prev:
    let
      call =
        pkgs: file:
        lib.callPackageWith (
          pkgs
          // {
            inherit inputs;
            unwrapped = prev;
          }
        ) file { };

      splat =
        file:
        let
          members = call final file;

          names = lib.attrNames (
            removeAttrs (call prev file) [
              "override"
              "overrideDerivation"
              "overrideAttrs"
            ]
          );
        in
        lib.genAttrs names (name: members.${name});
    in
    lib.mapAttrs (_: call final) singles // lib.concatMapAttrs (_: splat) groups;
in
{
  flake.overlays.default = overlay;

  perSystem =
    { pkgs, ... }:
    {
      packages = lib.getAttrs (lib.attrNames (overlay pkgs pkgs)) pkgs;
    };
}
