{ inputs, lib, ... }:
{
  flake.modules.homeManager.aion =
    { osConfig, pkgs, ... }:
    let
      monitors = inputs.self.monitors.${osConfig.networking.hostName} or { };

      modes = lib.concatStringsSep " " (
        lib.mapAttrsToList (name: m: "--output ${name} --mode ${m.mode}") (
          lib.filterAttrs (_: m: m.mode or null != null) monitors
        )
      );

      sessionService = description: exec: {
        Unit = {
          Description = description;
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = exec;
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    in
    {
      services.polkit-gnome.enable = true;

      systemd.user.services = {
        swaybg = sessionService "Wallpaper" "${pkgs.swaybg}/bin/swaybg -m fill -i ${../../../assets/wallpaper.png}";

        output-modes = lib.mkIf (modes != "") (
          lib.recursiveUpdate
            (sessionService "Output modes from flake.monitors" "${pkgs.wlr-randr}/bin/wlr-randr ${modes}")
            {
              Service = {
                Type = "oneshot";
                Restart = "no";
              };
            }
        );
      };
    };
}
