{ lib, ... }:
{
  options.flake.constants = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
    description = "Shared values";
  };

  config.flake.constants =
    let
      username = "boatette";
      release = "unstable";
    in
    {
      inherit release username;
      description = "Jonathan Clark";
      email = "boatette@gmail.com";

      flakeDir = "/home/${username}/nix";
      repo = "boatette/nix";

      # the branches nixpkgs and home-manager track for release
      nixpkgsBranch = "nixos-${release}";
      homeManagerBranch = if release == "unstable" then "master" else "release-${release}";

      locale = "en_AU.UTF-8";
      timeZone = "Australia/Hobart";
      stateVersion = "26.11";

      keyboard = {
        layout = "us";
        options = "caps:super";
      };

      fonts = {
        mono = {
          name = "JetBrainsMono Nerd Font";
          size = 12;
        };

        sans = {
          name = "Inter";
          size = 11;
        };
      };

      cursor = {
        name = "BreezeX-RosePine-Linux";
        size = 24;
      };

      # noctalia hardcodes these for what it doesn't expose, so everything else matches them
      glass = {
        radius = 12;
        opacity = 0.8;
      };

      # rosé pine main as rrggbb, for whatever has no rosé pine port
      palette = {
        base = "191724";
        surface = "1f1d2e";
        overlay = "26233a";
        muted = "6e6a86";
        subtle = "908caa";
        text = "e0def4";
        love = "eb6f92";
        gold = "f6c177";
        rose = "ebbcba";
        pine = "31748f";
        foam = "9ccfd8";
        iris = "c4a7e7";
        highlightLow = "21202e";
        highlightMed = "403d52";
        highlightHigh = "524f67";
      };

      # what each colour means, as noctalia's builtin rosé pine scheme assigns them
      roles = {
        primary = "rose";
        secondary = "foam";
        tertiary = "pine";
        warning = "gold";
        error = "love";
      };
    };

}
