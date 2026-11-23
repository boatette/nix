{ inputs, ... }:
{
  flake.modules.homeManager.boatette =
    let
      inherit (inputs.self.constants) palette;
    in
    {
      # the fill at ~15% alpha
      programs.selector.settings = {
        fill = "#${palette.rose}25";
        border = "#${palette.rose}";
      };
    };
}
