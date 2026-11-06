{
  flake.modules.homeManager.noctalia = {
    programs.noctalia = {
      enable = true;
      systemd.enable = true;
    };
  };
}
