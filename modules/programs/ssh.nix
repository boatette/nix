{
  flake.modules.homeManager.boatette = {
    services.ssh-agent.enable = true;

    programs.ssh = {
      enable = true;

      enableDefaultConfig = false;

      settings."*".AddKeysToAgent = "yes";
    };
  };
}
