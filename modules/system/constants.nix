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

      locale = "en_AU.UTF-8";
      timeZone = "Australia/Hobart";
      stateVersion = "26.05";

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
