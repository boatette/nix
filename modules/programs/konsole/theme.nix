{ inputs, ... }:
{
  flake-file.inputs.rose-pine-konsole = {
    url = "github:rose-pine/konsole";
    flake = false;
  };

  flake.modules.homeManager.konsole =
    { config, pkgs, ... }:
    let
      opacity = toString config.constants.glass.opacity;
    in
    {
      # the port is opaque; niri blurs behind it
      xdg.dataFile."konsole/rose-pine.colorscheme".source = pkgs.runCommand "rose-pine.colorscheme" { } ''
        sed 's/^Opacity=.*/Opacity=${opacity}/' ${inputs.rose-pine-konsole}/dist/rose-pine.colorscheme > $out
        grep -q '^Opacity=${opacity}$' $out
      '';
    };
}
