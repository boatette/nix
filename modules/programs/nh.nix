{ inputs, ... }:
{
  flake.modules.nixos.aspire =
    let
      inherit (inputs.self.constants) flakeDir;
      inherit (inputs.self.lib) rebuild;
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
