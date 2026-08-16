{
  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      programs.git = {
        enable = true;
        settings.user = {
          name = "boatette";
          email = "boatette@gmail.com";
        };
      };

      home.packages = [ pkgs.lazygit ];
    };
}
