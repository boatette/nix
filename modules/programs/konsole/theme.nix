{ inputs, ... }:
{
  flake-file.inputs.rose-pine-konsole = {
    url = "github:rose-pine/konsole";
    flake = false;
  };

  flake.modules.homeManager.konsole =
    { pkgs, ... }:
    {
      # the port is opaque; umbriel blurs behind it
      xdg.dataFile."konsole/rose-pine.colorscheme".source =
        pkgs.runCommand "rose-pine.colorscheme" { } ''
          sed 's/^Opacity=.*/Opacity=0.82/' ${inputs.rose-pine-konsole}/dist/rose-pine.colorscheme > $out
          grep -q '^Opacity=0.82$' $out
        '';
    };
}
