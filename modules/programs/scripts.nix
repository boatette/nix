{

  flake.modules.homeManager.scripts =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.libwebp
      ];
    };
}
