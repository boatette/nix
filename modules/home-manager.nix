{ inputs, ... }:

{
    flake.modules.nixos.base =
        { username, ... }:
        {
            imports = [ inputs.home-manager.nixosModules.home-manager ];

            home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs username; };
                backupFileExtension = "bak";
            };
        };

    flake.modules.homeManager.base =
        { username, ... }:
        {
            home = {
                inherit username;
                homeDirectory = "/home/${username}";
                stateVersion = "26.05";
            };
        };
}
