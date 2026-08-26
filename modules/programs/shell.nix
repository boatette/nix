{
  flake.modules.nixos.shell.programs.fish.enable = true;

  flake.modules.homeManager.shell.programs = {
    fish = {
      enable = true;
      interactiveShellInit = builtins.readFile ./shell/init.fish;
    };

    zoxide = {
      enable = true;
      options = [ "--cmd cd" ];
      enableFishIntegration = true;
    };
  };
}
