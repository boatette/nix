{

  flake.modules.homeManager.scripts =
    { pkgs, ... }:
    {
      home.packages = with pkgs.local; [
        open-zellij
        prune-small

        walls-optimise
        walls-pack
        walls-push
        walls-pull
      ];
    };
}
