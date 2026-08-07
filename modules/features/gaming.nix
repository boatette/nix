{
    flake.modules.nixos.workstation =
        { pkgs, ... }:
        {
            programs.steam = {
                enable = true;
                package = pkgs.millennium-steam;
            };

            programs.gamemode.enable = true;
        };
}
