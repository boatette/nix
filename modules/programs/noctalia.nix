{
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
        gpu-screen-recorder
        zip
      ];
    };
}
