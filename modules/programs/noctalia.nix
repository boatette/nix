{
  flake.modules.nixos.noctalia.programs.gpu-screen-recorder.enable = true;

  flake.modules.homeManager.noctalia =
    { pkgs, ... }:
    {
      programs.noctalia = {
        enable = true;
        systemd.enable = true;
      };

      home.packages = with pkgs; [
        imagemagick
        glib
        zip

        hyprpicker
        pulseaudio
        qrencode
        slurp
        (tesseract.override { enableLanguages = [ "eng" ]; })
        translate-shell
        wl-screenrec
        zbar
      ];
    };
}
