{ inputs, ... }:
{
  flake-file.inputs.rose-pine-foot = {
    url = "github:rose-pine/foot";
    flake = false;
  };

  flake.modules.homeManager.foot.programs.foot.settings.main.include =
    "${inputs.rose-pine-foot}/rose-pine";
}
