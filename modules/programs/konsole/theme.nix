{ inputs, ... }:
{
  flake-file.inputs.rose-pine-konsole = {
    url = "github:rose-pine/konsole";
    flake = false;
  };

  flake.modules.homeManager.konsole.xdg.dataFile."konsole/rose-pine.colorscheme".source =
    "${inputs.rose-pine-konsole}/dist/rose-pine.colorscheme";
}
