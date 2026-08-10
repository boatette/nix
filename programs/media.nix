{
    flake = {

        homeModules.desktop =
            { pkgs, ... }:
            {
                home.packages = with pkgs; [
                    ffmpeg
                    ffmpegthumbnailer

                    mpv
                    totem
                    amberol
                    qimgv
                ];
            };
    };
}
