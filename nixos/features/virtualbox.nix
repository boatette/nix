{
    flake.nixosModules.virtualbox =
        { config, ... }:
        {
            virtualisation.virtualbox.host.enable = true;
            users.extraGroups.vboxusers.members = [ config.preferences.user.name ];
        };
}
