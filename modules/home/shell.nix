{ config, ... }:

{
    programs = {
        starship = {
            enable = true;
            configPath = "${config.xdg.configHome}/starship/starship.toml";
        };

        zoxide = {
            enable = true;
            options = [ "--cmd cd" ];
        };
    };
}
