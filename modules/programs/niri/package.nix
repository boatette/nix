{ inputs, lib, ... }:
{

  config.flake.lib.mkNiri =
    pkgs: monitors:
    inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;

      imports = [ inputs.self.modules.niri.niri ];

      package = pkgs.niri;

      settings.outputs = lib.mapAttrs (
        _: m:
        {
          scale = m.scale or 1;
          transform = m.transform or "normal";

          position = _: {
            props = {
              x = m.position.x or 0;
              y = m.position.y or 0;
            };
          };
        }
        // lib.optionalAttrs (m.mode or null != null) { inherit (m) mode; }
      ) monitors;

      settings.extraConfig =
        let
          names = lib.attrNames monitors;
          primary = lib.findFirst (n: monitors.${n}.primary or false) null names;

          workspace =
            name:
            if primary == null then
              ''workspace "${name}"''
            else
              ''
                workspace "${name}" {
                    open-on-output "${primary}"
                }'';
        in
        ''
          ${lib.concatMapStringsSep "\n\n" workspace [
            "misc"
            "browser"
            "term"
          ]}

          include optional=true "~/.config/niri/noctalia.kdl"
        '';
    };
}
