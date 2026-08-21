{
  flake.modules.homeManager.git =
    {
      pkgs,
      config,
      ...
    }:
    {
      programs.git = {
        enable = true;
        settings.user = {
          name = config.constants.username;
          inherit (config.constants) email;
        };
      };

      home.packages = [ pkgs.lazygit ];
    };
}
