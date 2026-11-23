{
  inputs,
  lib,
  withSystem,
  ...
}:
{
  perSystem =
    { pkgs, ... }:
    {
      packages = lib.filesystem.packagesFromDirectoryRecursive {
        callPackage = pkgs.newScope { inherit inputs; };
        directory = ../../packages;
      };
    };

  flake.overlays.default = _final: prev: {
    local = withSystem prev.stdenv.hostPlatform.system ({ config, ... }: config.packages);
  };
}
