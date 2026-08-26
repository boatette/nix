{
  flake.modules.nixos.users =
    { config, pkgs, ... }:
    {
      users.users.${config.constants.username} = {
        isNormalUser = true;
        inherit (config.constants) description;
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        shell = pkgs.zsh;
      };
    };
}
