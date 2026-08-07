{ config, inputs, ... }:

let
    username = "boatette";
in
{
    flake.nixosConfigurations.redux = inputs.nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs username; };
        modules = [
            config.flake.modules.nixos.redux
            config.flake.modules.nixos.workstation
        ];
    };
}
