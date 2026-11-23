{
  flake.modules.homeManager.boatette = {
    programs.noctalia = {
      enable = true;
      systemd.enable = true;
    };
  };
}
