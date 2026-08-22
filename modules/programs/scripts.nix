{

  flake.modules.homeManager.scripts =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.local.open-zellij

        pkgs.libwebp
      ];
    };
}
