{ config, ... }:

{
    systems = [
        "x86_64-linux"
        "aarch64-linux"
    ];

    flake.nixosModules = config.flake.modules.nixos;
}
