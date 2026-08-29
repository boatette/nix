{
  perSystem =
    { config, pkgs, ... }:
    {
      devShells.default = pkgs.mkShellNoCC {
        packages = [
          config.formatter

          pkgs.deadnix
          pkgs.statix
        ];
      };
    };
}
