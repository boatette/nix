{ inputs, ... }:
{
  flake-file.inputs.millennium.url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";

  flake.modules.nixos.gaming =
    { pkgs, ... }:
    let
      inherit (pkgs.stdenv.hostPlatform) system;
    in
    {
      programs = {
        steam = {
          enable = true;
          package = inputs.millennium.packages.${system}.millennium-steam;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
        };

        gamemode.enable = true;
      };
    };
}
