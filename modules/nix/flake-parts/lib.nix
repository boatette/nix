{
  inputs,
  lib,
  withSystem,
  ...
}:
{
  options.flake.lib = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
    description = "Helper functions shared across the flake";
  };

  config.flake.lib.qtFont = font: "${font.name},${toString font.size},-1,5,50,0,0,0,0,0";

  config.flake.lib.mkNixos = system: name: {
    ${name} = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        inputs.self.modules.nixos.${name}
        {
          nixpkgs = {
            hostPlatform = lib.mkDefault system;
            pkgs = withSystem system ({ pkgs, ... }: pkgs);
          };
        }
      ];
    };
  };
}
