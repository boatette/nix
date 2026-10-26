{
  flake.modules.homeManager.aion =
    { pkgs, ... }:
    {
      services.polkit-gnome.enable = true;

      systemd.user.services.swaybg = {
        Unit = {
          Description = "Wallpaper";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.swaybg}/bin/swaybg -m fill -i ${../../../assets/wallpaper.png}";
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
}
