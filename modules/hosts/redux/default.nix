{ config, inputs, ... }:

let
    username = "boatette";
in
{
    flake.modules.nixos.hostRedux = {
        imports = with config.flake.modules.nixos; [
            redux

            base
            desktop
            dev
            gaming
        ];

        _module.args = { inherit username; };
    };

    flake.nixosConfigurations.redux = inputs.nixpkgs.lib.nixosSystem {
        modules = [ config.flake.modules.nixos.hostRedux ];
    };
}
