{ inputs, ... }:
{
  flake.modules.nixos.nh =
    { config, ... }:
    let
      inherit (config.constants) flakeDir;

      rebuild = inputs.self.lib.rebuild flakeDir;
    in
    {
      programs.nh = {
        enable = true;
        flake = flakeDir;

        clean = {
          enable = true;
          extraArgs = rebuild.cleanArgs;
        };
      };
    };
}
