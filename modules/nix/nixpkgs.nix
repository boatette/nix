{ inputs, ... }:
{
  flake-file.inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ inputs.self.overlays.default ];
      };
    };
}
