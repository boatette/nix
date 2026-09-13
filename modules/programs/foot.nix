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
            include = "${config.xdg.configHome}/foot/themes/noctalia";

            font = "${mono.name}:size=${toString mono.size}";

            pad = "14x14";
          };

          colors-dark.alpha = 0.8;

          csd.preferred = "none";
        };
      };
    };
}
