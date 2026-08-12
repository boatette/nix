{ inputs, self, ... }:

{
    flake.modules.nixos.base =
        { config, ... }:
        let
            username = config.preferences.user.name;
        in
        {
            imports = [ inputs.home-manager.nixosModules.home-manager ];

            home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = {
                    inherit inputs username;
                    inherit (config.preferences) monitors waylandSelect;
                };
                backupFileExtension = "bak";

                users.${username}.imports = [
                    self.modules.homeManager.base
                    self.modules.homeManager.dev
                ];
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
