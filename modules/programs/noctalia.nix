{
  flake.modules.homeManager.noctalia =
    { pkgs, ... }:
    {
      programs.noctalia = {
        enable = true;
        systemd.enable = true;
      };

      home.packages = [ pkgs.imagemagick ];
    };
}
