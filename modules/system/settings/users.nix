{
  flake.modules.nixos.users =
    { config, pkgs, ... }:
    {
      users.users.${config.constants.username} = {
        isNormalUser = true;
        homeMode = "711";
        inherit (config.constants) description;
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        shell = pkgs.zsh;
      };
    };
}
