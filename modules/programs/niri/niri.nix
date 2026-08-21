{ inputs, ... }:
{
  flake-file.inputs.wrapper-modules = {
    url = "github:BirdeeHub/nix-wrapper-modules";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.niri =
    { pkgs, ... }:
    {
      programs.niri = {
        enable = true;
        package = inputs.self.lib.mkNiri pkgs inputs.self.monitors;

        useNautilus = false;
      };
    };

  flake.modules.homeManager.niri =
    { pkgs, ... }:
    {
      xdg.configFile."niri/.keep".text = "";

      home.packages = with pkgs; [
        xwayland-satellite
        wl-clipboard
        libnotify
      ];
    };

  perSystem =
    { pkgs, ... }:
    {
      packages.niri = inputs.self.lib.mkNiri pkgs { };
    };
}
