{ inputs, ... }:

{
  flake.modules.nixos.base =
    { config, ... }:
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "bak";

        users.${config.preferences.user.name} = { };
      };
    };

  flake.modules.homeManager.base.home.stateVersion = "26.05";
}
