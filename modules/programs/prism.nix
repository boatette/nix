{
  flake.modules.homeManager.prism =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.prismlauncher ];
    };
}
