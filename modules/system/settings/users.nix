{
  flake.modules.nixos.users =
    { config, pkgs, ... }:
    {
      users.users.${config.constants.username} = {
        isNormalUser = true;
        # what nixos gave the account at install
        uid = 1000;
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
