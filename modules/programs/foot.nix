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

          # the rose-pine include sets [colors-dark], so the alpha goes there too
          colors-dark.alpha = 0.82;

          csd.preferred = "none";
        };
      };
    };
}
