{ inputs, lib, ... }:
{
  flake.modules.homeManager.noctalia =
    { config, osConfig, ... }:
    let
      inherit (inputs.self.lib) monitorProfiles parseMode;
      inherit (config.constants.glass) radius;

      host = osConfig.networking.hostName;
      profiles = monitorProfiles (inputs.self.monitors.${host} or { });
      # the compositor starts in the first profile; monitor-autorotate turns away from there
      monitors = lib.filterAttrs (_: m: m.mode != null) profiles.${lib.head (lib.attrNames profiles)};

      primary = lib.findFirst (name: monitors.${name}.primary or false) null (lib.attrNames monitors);

      isPortrait =
        m:
        lib.elem m.transform [
          90
          270
          "flipped-90"
          "flipped-270"
        ];

      # noctalia copies this whole section into its state file, shadowing this one, when an output
      # has no login box or the box wasn't placed for that output's logical size. enabled = false
      # still counts, which is how every output but the primary stays empty
      logicalSize =
        m:
        let
          mode = parseMode m.mode;
          portrait = isPortrait m;
          physicalWidth = lib.toInt mode.width * 1.0;
          physicalHeight = lib.toInt mode.height * 1.0;
        in
        {
          width = (if portrait then physicalHeight else physicalWidth) / m.scale;
          height = (if portrait then physicalWidth else physicalHeight) / m.scale;
        };

      # laid out on a 1920x1080 screen, then scaled onto the output
      x = m: n: n * (logicalSize m).width / 1920.0;
      y = m: n: n * (logicalSize m).height / 1080.0;

      # noctalia's compact login box: 400 wide, and 38 plus 16 of padding on each side tall.
      # its panel opacity is 0.88, not the shared glass opacity
      loginSettings = {
        background_color = "surface_container";
        background_opacity = 0.88;
        background_radius = radius * 1.0;

        layout = "compact";

        center_password_text = false;
        input_opacity = 1.0;
        input_radius = 6.0;

        show_caps_lock = true;
        show_keyboard_layout = true;
        show_login_button = true;
        show_password_reveal = true;

        show_media = false;
        show_session_buttons = false;
        show_unlock_hint = false;
        show_weather = false;
      };

      loginBox =
        output: m:
        let
          size = logicalSize m;
        in
        lib.nameValuePair "lockscreen-login-box@${output}" {
          inherit output;
          enabled = output == primary;
          type = "login_box";

          placement_width = size.width;
          placement_height = size.height;

          box_width = 400.0;
          box_height = 70.0;
          rotation = 0.0;

          cx = x m 960.0;
          cy = y m 940.0;

          settings = loginSettings;
        };

      # one counter id, the form noctalia assigns itself
      clockId = "lockscreen-widget-0000000000000001";

      clock =
        let
          m = monitors.${primary};
          size = logicalSize m;
        in
        {
          ${clockId} = {
            output = primary;
            type = "clock";

            placement_width = size.width;
            placement_height = size.height;

            box_width = x m 368.0;
            box_height = y m 208.0;
            rotation = 0.0;

            cx = x m 960.0;
            cy = y m 292.0;

            settings = {
              background = false;
              center_text = true;
              clock_style = "digital";
              shadow = false;
            };
          };
        };

      # primary first, then the rest by name, then the clock
      widgetOrder =
        let
          others = lib.sort lib.lessThan (lib.filter (name: name != primary) (lib.attrNames monitors));
        in
        (map (output: "lockscreen-login-box@${output}") ([ primary ] ++ others)) ++ [ clockId ];
    in
    lib.throwIf (primary == null)
      "noctalia/lockscreen-widgets.nix: no monitor in flake.monitors.${host} is marked `primary = true`"
      {
        programs.noctalia.settings.lockscreen_widgets = {
          enabled = true;
          schema_version = 2;

          widget_order = widgetOrder;

          grid = {
            cell_size = 16;
            major_interval = 4;
            visible = true;
          };

          widget = lib.mapAttrs' loginBox monitors // clock;
        };
      };
}
