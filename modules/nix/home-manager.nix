{ config, lib, ... }:

{
  flake.modules.nixos = lib.mapAttrs (_: homeModule: {
    home-manager.sharedModules = [ homeModule ];
  }) config.flake.modules.homeManager;
}
