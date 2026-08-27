{
  flake.modules.nixos.gaming = {
    programs = {
      steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
      };

      gamemode.enable = true;
    };
  };
}
