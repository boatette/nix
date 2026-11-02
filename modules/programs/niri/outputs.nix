{ inputs, lib, ... }:
{
  flake.modules.homeManager.niri =
    { osConfig, ... }:
    let
      profiles = inputs.self.lib.monitorProfiles (
        inputs.self.monitors.${osConfig.networking.hostName} or { }
      );
    in
    {
      wayland.windowManager.niri.settings._children = lib.mapAttrsToList (name: m: {
        output = {
          _args = [ name ];
          inherit (m) scale;
          transform = if m.transform == 0 then "normal" else toString m.transform;
          position._props = m.position;
        }
        // lib.optionalAttrs (m.mode != null) { inherit (m) mode; };
      }) (lib.head (lib.attrValues profiles));
    };
}
