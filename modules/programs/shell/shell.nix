{
  flake.modules.nixos.shell.programs.fish.enable = true;

  flake.modules.homeManager.shell.programs = {
    fish = {
      enable = true;
      interactiveShellInit = builtins.readFile ./init.fish;
    };

    zoxide = {
      enable = true;
      options = [ "--cmd cd" ];
      enableFishIntegration = true;
    };
  };
}
