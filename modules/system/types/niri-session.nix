{ inputs, ... }:
{

  flake.modules.nixos.niri-session =
    { config, ... }:
    {
      imports = [ inputs.self.modules.nixos.niri ];

      home-manager.users.${config.constants.username}.imports = with inputs.self.modules.homeManager; [
        niri
        noctalia-niri
      ];
    };
}
