{ inputs, lib, ... }:
{
  flake-file.inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          # FIX: revert on qtwebengine fix
          # qtwebengine still trusts the revoked eMudhra intermediates (2026-11)
          allowInsecurePredicate =
            pkg:
            builtins.elem (lib.getName pkg) [
              "qutebrowser"
              "ventoy"
            ];
        };
        overlays = [ inputs.self.overlays.default ];
      };
    };
}
