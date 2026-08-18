{ inputs, ... }:

{
  flake.modules.homeManager.desktop =
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
