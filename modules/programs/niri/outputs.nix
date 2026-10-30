{ inputs, lib, ... }:
{
  flake.modules.homeManager.niri =
    { osConfig, ... }:
    let
      profiles = inputs.self.lib.monitorProfiles (
        inputs.self.monitors.${osConfig.networking.hostName} or { }
      );

      # niri starts in the first profile by name; monitor-autorotate turns it from there
      monitors = profiles.${lib.head (lib.attrNames profiles)};

      output = name: m: {
        output = {
          _args = [ name ];
          scale = m.scale * 1.0;
          transform = if m.transform == 0 then "normal" else toString m.transform;
          position._props = {
            inherit (m.position) x y;
          };
        }
        // lib.optionalAttrs (m.mode != null) { inherit (m) mode; };
      };
    in
    {
      wayland.windowManager.niri.settings._children = lib.mapAttrsToList output monitors;
    };
}
