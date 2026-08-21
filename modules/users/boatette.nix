{ inputs, ... }:
{

  flake.modules.nixos.boatette =
    { config, ... }:
    {
      home-manager.users.${config.constants.username} = {
        imports = [ inputs.self.modules.homeManager.boatette ];
      };
    };

  flake.modules.homeManager.boatette =
    { config, ... }:
    {
      imports = [ inputs.self.modules.homeManager.desktop ];

      home.stateVersion = config.constants.stateVersion;
    };
}
