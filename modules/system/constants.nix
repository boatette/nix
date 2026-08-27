{ inputs, lib, ... }:
{
  options.flake.constants = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
    description = "Shared values";
  };

  config.flake.constants = {
    username = "boatette";
    description = "Jonathan Clark";
    email = "boatette@gmail.com";

    flakeDir = "~/nix";

    locale = "en_AU.UTF-8";
    timeZone = "Australia/Hobart";
    stateVersion = "26.05";
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
