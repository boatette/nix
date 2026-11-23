{
  flake.modules.homeManager.vm =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.quickemu ];
    };
}
