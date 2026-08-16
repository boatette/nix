{
  config,
  inputs,
  lib,
  ...
}:

let
  nixpkgsConfig = {
    allowUnfree = true;

    allowInsecurePredicate = pkg: lib.getName pkg == "ventoy";
  };

  overlays = [
    inputs.claude-code.overlays.default
    config.flake.overlays.default
  ];
in
{
  flake.modules.nixos.base.nixpkgs = {
    config = nixpkgsConfig;
    inherit overlays;
  };

  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system overlays;
        config = nixpkgsConfig;
      };
    };
}
