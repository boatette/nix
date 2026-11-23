{ inputs, lib, ... }:
{
  flake.modules.homeManager.boatette =
    { osConfig, pkgs, ... }:
    let
      inherit (inputs.self.lib) startLayout umbrielLayout;

      layout = startLayout osConfig.networking.hostName;
    in
    {
      # included rather than set here, so monitor-autorotate's include, read after it, can turn the outputs
      programs.umbriel.settings.include.files = [ "${umbrielLayout pkgs "start" layout}" ];

      programs.umbriel.settings.output = lib.mapAttrs (
        _: m:
        {
          scale = m.scale * 1.0;

          workspaces = "dynamic";
          min_workspaces = 5;
        }
        // lib.optionalAttrs (m.mode != null) { inherit (m) mode; }
      ) layout;
    };
}
