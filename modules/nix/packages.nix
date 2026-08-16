{ inputs, lib, ... }:

let
  files = ((inputs.import-tree.addPath ./..).filter (lib.hasSuffix ".pkg.nix")).files;

  named = lib.listToAttrs (
    map (file: lib.nameValuePair (lib.removeSuffix ".pkg.nix" (baseNameOf file)) file) files
  );
in
{
  flake.overlays.default =
    final: prev:
    lib.mapAttrs (
      _: file:
      lib.callPackageWith (
        final
        // {
          inherit inputs;
          unwrapped = prev;
        }
      ) file { }
    ) named;

  perSystem =
    { pkgs, ... }:
    {
      packages = lib.getAttrs (lib.attrNames named) pkgs;
    };
}
