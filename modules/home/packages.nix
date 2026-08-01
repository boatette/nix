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
        ])
        ++ [
            inputs.claude-code.packages.${system}.default
            inputs.noctalia.packages.${system}.default
            inputs.wayland-select.packages.${system}.default
            inputs.zen-browser.packages.${system}.default
        ];
}
