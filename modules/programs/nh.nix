{ inputs, ... }:
{
  flake.modules.nixos.aspire =
    let
      inherit (inputs.self.constants) flakeDir;

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
