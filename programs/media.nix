{
    flake =
        let
            gstPackages =
                pkgs: with pkgs.gst_all_1; [
                    gstreamer
                    gst-plugins-base
                    gst-plugins-good
                    gst-plugins-bad
                    gst-plugins-ugly
                    gst-libav
                ];
        in
        {
            nixosModules.desktop =
                { pkgs, lib, ... }:
                {
                    environment.sessionVariables.GST_PLUGIN_SYSTEM_PATH_1_0 =
                        lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0"
                            (gstPackages pkgs);
                };

            homeModules.desktop =
                { pkgs, ... }:
                {
                    home.packages =
                        gstPackages pkgs
                        ++ (with pkgs; [
                            ffmpeg
                            ffmpegthumbnailer

                            mpv
                            totem
                            amberol
                            qimgv
                        ]);
                };
        };
}
