{
  flake.modules.nixos.luciole =
    { config, ... }:
    {
      xdg.portal.extraPortals = [ config.programs.luciole.package ];
    };
}
