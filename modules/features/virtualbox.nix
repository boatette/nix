{
    flake.modules.nixos.desktop =
        { username, ... }:
        {
            virtualisation.virtualbox.host.enable = true;
            users.extraGroups.vboxusers.members = [ username ];
        };
}
