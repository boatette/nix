{

  flake.modules.homeManager.scripts =
    { pkgs, ... }:
    {
      home.packages = with pkgs.local; [
        open-zellij
        walls
      ];
    };
}
