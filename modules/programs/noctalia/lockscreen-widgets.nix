{ inputs, lib, ... }:
{
  flake.modules.homeManager.noctalia =
    { config, osConfig, ... }:
    let
      inherit (inputs.self.lib) monitorProfiles parseMode;
      inherit (config.constants.glass) radius opacity;

      profiles = monitorProfiles (inputs.self.monitors.${osConfig.networking.hostName} or { });
      monitors = lib.filterAttrs (_: m: m.mode != null) profiles.${lib.head (lib.attrNames profiles)};

      # noctalia saves its own copy of this section to the state file, shadowing this one, if an
      # output has no login box or the box wasn't placed for the output's size
      loginBox =
        output: m:
        let
          mode = parseMode m.mode;
          width = lib.toInt mode.width * 1.0;
          height = lib.toInt mode.height * 1.0;
        in
        lib.nameValuePair "lockscreen-login-box@${output}" {
          inherit output;
          type = "login_box";

          placement_width = width;
          placement_height = height;

          # noctalia's default spot for its 196px tall box, 84px up from the bottom
          cx = width / 2;
          cy = height - 84 - 196 / 2;

          settings = {
            background_opacity = opacity;
            background_radius = radius * 1.0;
          };
        };
    in
    {
      programs.noctalia.settings.lockscreen_widgets.widget = lib.mapAttrs' loginBox monitors;
    };
}
