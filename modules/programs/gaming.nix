{ inputs, ... }:
{
  flake-file.inputs.millennium = {
    url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.gaming =
    { pkgs, ... }:
    let
      inherit (pkgs.stdenv.hostPlatform) system;
    in
    {
      programs = {
        steam = {
          enable = true;

          package = inputs.millennium.packages.${system}.millennium-steam.override {
            extraArgs = "-cef-disable-gpu";
          };

          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
        };

        gamemode.enable = true;

        gamescope = {
          enable = true;
          capSysNice = true;
        };
      };
    };
}
