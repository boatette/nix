{
  flake.modules.homeManager.boatette =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.quickemu ];
    };
}
