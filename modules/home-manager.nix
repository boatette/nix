{ config, inputs, ... }:

{
    flake.modules.nixos.workstation =
        { username, ... }:
        {
            imports = [ inputs.home-manager.nixosModules.home-manager ];

            home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs username; };
                backupFileExtension = "bak";

                users.${username} = config.flake.modules.homeManager.workstation;
            };
        };

    flake.modules.homeManager.workstation =
        { username, ... }:
        {
            home = {
                inherit username;
                homeDirectory = "/home/${username}";
                stateVersion = "26.05";
            };
        };
}
