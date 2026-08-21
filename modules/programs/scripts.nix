{

  flake.modules.homeManager.scripts =
    { pkgs, ... }:
    {
      home.packages = with pkgs.local; [
        omarchy-import
        open-zellij
        walls
      ];
    };
}
