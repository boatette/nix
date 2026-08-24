{
  flake.modules.nixos.shell =
    { lib, ... }:
    {
      programs.fish.enable = true;
      environment.shellAliases = lib.mkForce { };
    };

  flake.modules.homeManager.shell =
    {
      pkgs,
      lib,
      ...
    }:
    {
      programs = {
        fish = {
          enable = true;

          interactiveShellInit = lib.mkMerge [
            (builtins.readFile ./init.fish)

            (lib.mkAfter ''
              ${lib.getExe pkgs.zoxide} init fish --cmd cd | source
            '')
          ];
        };

        zoxide = {
          enable = true;
          options = [ "--cmd cd" ];
          enableFishIntegration = false;
        };
      };
    };
}
