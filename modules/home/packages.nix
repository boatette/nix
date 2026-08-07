{ pkgs, inputs, ... }:

let
    inherit (pkgs.stdenv.hostPlatform) system;
in

{
    home.packages =
        (with pkgs; [
            foot
            wl-clipboard
            libnotify
            xwayland-satellite

            vesktop
            nautilus
            qimgv
            mpv
            gimp
            prismlauncher
            stremio-linux-shell
            amberol

            ffmpeg
            ffmpegthumbnailer
            totem

            gst_all_1.gstreamer
            gst_all_1.gst-plugins-base
            gst_all_1.gst-plugins-good
            gst_all_1.gst-plugins-bad
            gst_all_1.gst-plugins-ugly
            gst_all_1.gst-libav

            bat
            btop
            dust
            eza
            fastfetch
            fd
            fzf
            jq
            lazygit
            lm_sensors
            ripgrep
            unzip
            zstd

            gcc
            gnumake
            go
            nodejs
            python3
            rustup
            tree-sitter

            figlet

            libreoffice-qt
            hunspell

            qbittorrent
        ])
        ++ [
            inputs.claude-code.packages.${system}.default
            inputs.noctalia.packages.${system}.default
            inputs.wayland-select.packages.${system}.default
            inputs.zen-browser.packages.${system}.default
        ];
}
