{ inputs, withSystem, ... }:
{
  flake.nixosConfigurations.aspire = inputs.nixpkgs.lib.nixosSystem {
    modules = [ inputs.self.modules.nixos.aspire ];
  };

  flake.modules.nixos.aspire = {
    networking.hostName = "aspire";

    nixpkgs = {
      hostPlatform = "x86_64-linux";
      pkgs = withSystem "x86_64-linux" ({ pkgs, ... }: pkgs);
    };

    system.stateVersion = inputs.self.constants.stateVersion;
  };
}
