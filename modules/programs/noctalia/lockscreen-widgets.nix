{ inputs, lib, ... }:
{
  flake.modules.homeManager.noctalia =
    { config, osConfig, ... }:
    let
      inherit (inputs.self.lib) noctaliaWidget primaryMonitor startLayout;

      host = osConfig.networking.hostName;
      primary = primaryMonitor host;
      widget = noctaliaWidget host;

      # every output gets a login box, or noctalia makes its own and copies this whole section into
      # its state file. enabled = false still counts, which is how all but the primary stay empty
      outputs = lib.attrNames (lib.filterAttrs (_: m: m.mode != null) (startLayout host));

      # noctalia's compact login box: 400 wide, and 38 plus 16 of padding on each side tall.
      # its panel opacity is 0.88, not the shared glass opacity
      loginBox =
        output:
        lib.nameValuePair "lockscreen-login-box@${output}" (
          widget output {
            enabled = output == primary;
            type = "login_box";
            rotation = 0.0;

            box_width = 400.0;
            box_height = 70.0;

            box = {
              cx = 960.0;
              cy = 940.0;
            };

            settings = {
              background_color = "surface_container";
              background_opacity = 0.88;
              background_radius = config.constants.glass.radius * 1.0;

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
          }
        );

      # counter ids, the form noctalia assigns itself
      clockId = "lockscreen-widget-0000000000000001";
      dateId = "lockscreen-widget-0000000000000002";

      # a clock's text fills its box, so the date's shorter box above the time keeps it smaller;
      # 560 wide lets the height set that size even for "Wednesday, September 30"
      clock = id: box: settings: {
        ${id} = widget primary {
          type = "clock";
          rotation = 0.0;
          inherit box;

          settings = {
            background = false;
            center_text = true;
            clock_style = "digital";
            shadow = false;
          }
          // settings;
        };
      };
    in
    {
      programs.noctalia.settings.lockscreen_widgets = {
        enabled = true;
        schema_version = 2;

        # primary first, then the rest by name, then the clock and the date
        widget_order =
          map (output: "lockscreen-login-box@${output}") ([ primary ] ++ lib.remove primary outputs)
          ++ [
            clockId
            dateId
          ];

        grid = {
          cell_size = 16;
          major_interval = 4;
          visible = true;
        };

        widget =
          lib.listToAttrs (map loginBox outputs)
          // clock clockId {
            width = 368.0;
            height = 208.0;
            cx = 960.0;
            cy = 292.0;
          } { }
          // clock dateId {
            width = 560.0;
            height = 50.0;
            cx = 960.0;
            cy = 161.0;
          } { format = "{:%A, %B %d}"; };
      };
    };
}
