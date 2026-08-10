{ inputs, ... }:

{
    flake.homeModules.desktop =
        { pkgs, ... }:
        let
            inherit (pkgs.stdenv.hostPlatform) system;

            prismlauncher = pkgs.symlinkJoin {
                name = "prismlauncher-offload";
                paths = [ pkgs.prismlauncher ];
                nativeBuildInputs = [ pkgs.makeWrapper ];
                postBuild = ''
                    wrapProgram $out/bin/prismlauncher \
                        --set-default __NV_PRIME_RENDER_OFFLOAD 1 \
                        --set-default __NV_PRIME_RENDER_OFFLOAD_PROVIDER NVIDIA-G0 \
                        --set-default __GLX_VENDOR_LIBRARY_NAME nvidia \
                        --set-default __VK_LAYER_NV_optimus NVIDIA_only
                '';
            };
        in
        {
            dconf.settings."org/cinnamon/desktop/applications/terminal" = {
                exec = "foot";
                exec-arg = "--";
            };

            home.packages =
                (with pkgs; [
                    nemo-with-extensions
                    file-roller
                    p7zip
                    vesktop
                    gimp
                    stremio-linux-shell
                    qbittorrent

                    libreoffice-qt
                    hunspell
                ])
                ++ [
                    prismlauncher
                    inputs.zen-browser.packages.${system}.default
                ];
        };
}
