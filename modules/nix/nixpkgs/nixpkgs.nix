{ inputs, ... }:
let
  config.allowUnfree = true;
in
{
  flake-file.inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  flake.modules.nixos.nixpkgs.nixpkgs = { inherit config; };

  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs { inherit system config; };
    };
}
