{ inputs, lib, ... }:
{
  options.flake.constants = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
    description = "Shared values";
  };

  config.flake.constants =
    let
      username = "boatette";
    in
    {
      inherit username;
      description = "Jonathan Clark";
      email = "boatette@gmail.com";

      flakeDir = "/home/${username}/nix";
      repo = "boatette/nix";

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

      # the look of everything translucent; noctalia hardcodes these same values for what it
      # doesn't expose, a 12 radius on its panels and toasts and 0.8 on its settings window
      glass = {
        radius = 12;
        opacity = 0.8;
      };

      # rosé pine main, as rrggbb, for whatever has no rosé pine port
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
      };
    };

  config.flake.modules.generic.constants =
    { lib, ... }:
    {
      options.constants = lib.mkOption {
        type = lib.types.attrsOf lib.types.unspecified;
        default = { };
        description = "Values shared across configuration contexts";
      };

      config.constants = inputs.self.constants;
    };
}
