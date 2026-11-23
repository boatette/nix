{
  flake.modules.nixos.aspire =
    { pkgs, ... }:
    {
      programs = {
        steam = {
          enable = true;

          package = pkgs.steam.override { extraArgs = "-cef-disable-gpu"; };

          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
        };

        gamemode.enable = true;

        gamescope = {
          enable = true;
          capSysNice = true;
        };
      };
    };
}
