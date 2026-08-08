{ inputs, self, ... }:

{
    flake.nixosModules.base =
        { config, ... }:
        let
            username = config.preferences.user.name;
        in
        {
            imports = [ inputs.home-manager.nixosModules.home-manager ];

            home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs username; };
                backupFileExtension = "bak";

                users.${username}.imports = [
                    self.homeModules.base
                    self.homeModules.dev
                ];
            };
        };

    flake.homeModules.base =
        { username, ... }:
        {
            home = {
                inherit username;
                homeDirectory = "/home/${username}";
                stateVersion = "26.05";
            };
        };
}
