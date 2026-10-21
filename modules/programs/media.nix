{
  flake.modules.homeManager.media =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        ffmpeg
        libwebp

        qimgv
        mpv
      ];
    };
}
