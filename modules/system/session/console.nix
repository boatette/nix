{ inputs, ... }:
{
  flake.modules.nixos.aspire =
    { pkgs, ... }:
    {
      console = {
        earlySetup = true;

        packages = [ pkgs.terminus_font ];
        font = "ter-v24b";

        # the 16 ansi colours, the bright ones the same apart from black
        colors = with inputs.self.constants.palette; [
          base
          love
          pine
          gold
          foam
          iris
          rose
          text
          muted
          love
          pine
          gold
          foam
          iris
          rose
          text
        ];
      };
    };
}
