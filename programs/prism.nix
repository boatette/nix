{
    flake.modules.homeManager.desktop =
        { pkgs, ... }:
        {
            home.packages = [
                (pkgs.symlinkJoin {
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
                })
            ];
        };
}
