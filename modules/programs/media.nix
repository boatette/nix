{
  flake.modules.homeManager.media =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        ffmpeg
        libwebp

        ffmpegthumbnailer

        qimgv
        mpv
        amberol
      ];
    };
}
