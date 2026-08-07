{ config, lib, ... }:

let
    roles = [
        "base"
        "desktop"
        "dev"
        "gaming"
    ];
in
{
    flake.modules.nixos = lib.genAttrs roles (
        role:
        { username, ... }:
        {
            home-manager.users.${username}.imports = [
                (config.flake.modules.homeManager.${role} or { })
            ];
        }
    );
}
