{ inputs, ... }:
{
  flake-file.inputs.helium = {
    url = "github:oxcl/nix-flake-helium-browser";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.apps =
    { pkgs, ... }:
    let
      inherit (pkgs.stdenv.hostPlatform) system;
    in
    {
      home.packages =
        (with pkgs; [
          vesktop
          gimp
          stremio-linux-shell
          qbittorrent
          proton-pass

          libreoffice-qt
          hunspell
        ])
        ++ [
          inputs.helium.packages.${system}.default
        ];
    };
}
