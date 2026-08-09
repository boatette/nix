{
    flake.homeModules.desktop =
        { pkgs, ... }:
        {
            home.packages = [ pkgs.foot ];
        };
}
