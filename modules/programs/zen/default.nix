{ inputs, ... }:

{
  flake.modules.homeManager.desktop =
    { pkgs, ... }:
    {
      home.packages = [
        (import ./_package.nix { inherit inputs pkgs; })
        (import ./_reload.nix { inherit pkgs; })
      ];
    };

  perSystem =
    { pkgs, ... }:
    {
      packages.zen-beta = import ./_package.nix { inherit inputs pkgs; };
      packages.zen-theme-reload = import ./_reload.nix { inherit pkgs; };
    };
}
