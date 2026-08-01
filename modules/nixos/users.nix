{ pkgs, username, ... }:

{
    users.users.${username} = {
        isNormalUser = true;
        description = "Jonathan Clark";
        extraGroups = [
            "networkmanager"
            "wheel"
        ];
        shell = pkgs.fish;
    };
}
