{ inputs, ... }:
{
  flake.modules.nixos.aspire =
    { config, pkgs, ... }:
    let
      inherit (config.constants) description username;
    in
    {
      users.users.${username} = {
        isNormalUser = true;
        # what nixos gave the account at install
        uid = 1000;
        homeMode = "711";
        inherit description;
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        shell = pkgs.zsh;
      };

      # shared rather than imported per user, so nixd's option completion sees them
      home-manager = {
        sharedModules = [ inputs.self.modules.homeManager.boatette ];
        users.${username} = { };
      };
    };

  flake.modules.homeManager.boatette =
    { config, ... }:
    {
      imports = [ inputs.self.modules.generic.constants ];

      home.stateVersion = config.constants.stateVersion;
    };
}
