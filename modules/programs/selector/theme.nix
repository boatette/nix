{ inputs, ... }:
{
  flake.modules.homeManager.boatette.programs.selector.settings =
    let
      inherit (inputs.self.lib.colours) alpha hex;
    in
    {
      fill = alpha "primary" 0.15;
      border = hex "primary";
    };
}
