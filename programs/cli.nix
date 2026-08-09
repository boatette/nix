{ inputs, ... }:

{
    flake.homeModules.dev =
        { pkgs, ... }:
        let
            inherit (pkgs.stdenv.hostPlatform) system;
        in
        {
            home.packages =
                (with pkgs; [
                    btop
                    dust
                    eza
                    fd
                    fzf
                    jq
                    lm_sensors
                    ripgrep
                    unzip
                    zstd
                ])
                ++ [
                    inputs.claude-code.packages.${system}.default
                ];
        };
}
