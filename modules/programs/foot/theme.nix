{
  flake.modules.homeManager.noctalia =
    { pkgs, lib, ... }:
    {
      programs.noctalia.settings.hooks.colors_changed = [
        (lib.getExe pkgs.local.foot-live-theme)
      ];
    };
}
