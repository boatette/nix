{ inputs, withSystem, ... }:
{
  flake.overlays.default = _final: prev: {
    local = withSystem prev.stdenv.hostPlatform.system ({ config, ... }: config.packages);
  };

  flake.modules.nixos.pkgs-by-name.nixpkgs.overlays = [ inputs.self.overlays.default ];
}
