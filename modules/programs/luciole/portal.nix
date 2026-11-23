{
  flake.modules.nixos.aspire =
    { config, ... }:
    {
      xdg.portal.extraPortals = [ config.programs.luciole.package ];
    };
}
