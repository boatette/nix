{
  perSystem =
    { config, pkgs, ... }:
    {
      devShells.default = pkgs.mkShellNoCC {
        packages = [
          config.formatter

          pkgs.age
          pkgs.deadnix
          pkgs.sops
          pkgs.statix
        ];
      };
    };
}
