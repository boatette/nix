{ inputs, ... }:
{
  flake.modules.homeManager.boatette =
    let
      inherit (inputs.self.constants.fonts) mono;
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
          colors-dark.alpha = inputs.self.constants.glass.opacity;

          csd.preferred = "none";
        };
      };
    };
}
