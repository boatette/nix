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

          libreoffice-qt
          hunspell
        ])
        ++ [
          inputs.zen-browser.packages.${system}.default
          inputs.helium.packages.${system}.default
        ];
    };
}
