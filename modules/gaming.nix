{
    flake.modules.nixos.gaming =
        { pkgs, ... }:
        {
            programs.steam = {
                enable = true;
                package = pkgs.millennium-steam;
            };

            programs.gamemode.enable = true;
        };
}
