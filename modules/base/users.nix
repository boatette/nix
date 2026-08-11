{
    flake.modules.nixos.base =
        { config, pkgs, ... }:
        {
            users.users.${config.preferences.user.name} = {
                isNormalUser = true;
                inherit (config.preferences.user) description;
                extraGroups = [
                    "networkmanager"
                    "wheel"
                ];
                shell = pkgs.fish;
            };
        };
}
