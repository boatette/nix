{
  flake.modules.homeManager.foot =
    { config, ... }:
    let
      inherit (config.constants.fonts) mono;
    in
    {
      programs.foot = {
        enable = true;

        settings = {
          main = {
            font = "${mono.name}:size=${toString mono.size}";

            pad = "14x14";
          };

          csd.preferred = "none";
        };
      };
    };
}
