{ inputs, ... }:
{

  flake.modules.nixos.umbriel-session =
    { config, ... }:
    {
      imports = [ inputs.self.modules.nixos.umbriel ];

      services.displayManager.defaultSession = "umbriel";

      home-manager.users.${config.constants.username}.imports = with inputs.self.modules.homeManager; [
        umbriel
        noctalia-umbriel
      ];
    };
}
