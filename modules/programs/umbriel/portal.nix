{ inputs, ... }:
{
  flake-file.inputs.xdg-desktop-portal-umbriel = {
    url = "github:noctalia-dev/xdg-desktop-portal-umbriel";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.umbriel =
    { pkgs, ... }:
    let
      inherit (pkgs.stdenv.hostPlatform) system;

      backend = inputs.xdg-desktop-portal-umbriel.packages.${system}.default;
    in
    {
      xdg.portal = {
        enable = true;

        configPackages = [ backend ];

        extraPortals = [
          backend
          pkgs.xdg-desktop-portal-gtk
        ];
      };
    };

  perSystem =
    { system, ... }:
    {
      packages.xdg-desktop-portal-umbriel = inputs.xdg-desktop-portal-umbriel.packages.${system}.default;
    };
}
