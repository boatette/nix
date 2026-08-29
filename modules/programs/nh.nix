{
  flake.modules.nixos.nh =
    { config, ... }:
    {
      programs.nh = {
        enable = true;
        flake = config.constants.flakeDir;

        clean = {
          enable = true;
          extraArgs = "--keep 5 --keep-since 7d";
        };
      };

      environment.sessionVariables.NH_ELEVATION_STRATEGY = "/run/current-system/sw/bin/run0";
    };
}
