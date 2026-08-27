{ inputs, ... }:
{
  flake-file.inputs.millennium = {
    url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.gaming =
    { pkgs, ... }:
    {
      nixpkgs.overlays = [ inputs.millennium.overlays.default ];

      programs = {
        steam = {
          enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
          package = pkgs.millennium-steam;
        };

        gamemode.enable = true;
      };
    };
}
