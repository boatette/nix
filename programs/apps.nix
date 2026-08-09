{ inputs, ... }:

{
    flake.homeModules.desktop =
        { pkgs, ... }:
        let
            inherit (pkgs.stdenv.hostPlatform) system;
        in
        {
            home.packages =
                (with pkgs; [
                    nautilus
                    vesktop
                    gimp
                    prismlauncher
                    stremio-linux-shell
                    qbittorrent

                    libreoffice-qt
                    hunspell
                ])
                ++ [
                    inputs.zen-browser.packages.${system}.default
                    inputs.wayland-select.packages.${system}.default
                ];
        };
}
