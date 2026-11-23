{
  flake.modules.homeManager.boatette =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        ffmpeg
        libwebp

        mpv
        qimgv
      ];
    };
}
