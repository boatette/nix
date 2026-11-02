{ inputs, lib, ... }:
{
  flake.modules.homeManager.umbriel =
    { osConfig, ... }:
    let
      profiles = inputs.self.lib.monitorProfiles (
        inputs.self.monitors.${osConfig.networking.hostName} or { }
      );

      # umbriel starts in the first profile by name; monitor-autorotate turns it from there
      monitors = profiles.${lib.head (lib.attrNames profiles)};

      isPortrait =
        m:
        lib.elem m.transform [
          90
          270
          "flipped-90"
          "flipped-270"
        ];
    in
    {
      programs.umbriel.settings.output = lib.mapAttrs (
        _: m:
        {
          scale = m.scale * 1.0;
          transform = if m.transform == 0 then "normal" else toString m.transform;

          position = [
            m.position.x
            m.position.y
          ];

          min_workspaces = 10;

          workspace_axis = if isPortrait m then "horizontal" else "vertical";
        }
        // lib.optionalAttrs (m.mode != null) { inherit (m) mode; }
      ) monitors;
    };
}
