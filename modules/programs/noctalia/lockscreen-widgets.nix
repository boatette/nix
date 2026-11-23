{ inputs, lib, ... }:
{
  flake.modules.homeManager.boatette =
    let
      inherit (inputs.self.lib) startLayout;

      primary = inputs.self.lib.primaryMonitor;
      widget = inputs.self.lib.noctaliaWidget;

      # without a login box on every output noctalia adds its own to its state; disabled ones still count
      outputs = lib.attrNames (lib.filterAttrs (_: m: m.mode != null) startLayout);

      # noctalia's compact login box: 400 wide, and 38 plus 16 of padding on each side tall
      loginBox =
        output:
        lib.nameValuePair "lockscreen-login-box@${output}" (
          widget output {
            enabled = output == primary;
            type = "login_box";

            box_width = 400.0;
            box_height = 70.0;

            box = {
              cx = 960.0;
              cy = 940.0;
            };

            settings = {
              layout = "compact";
              background_radius = inputs.self.constants.glass.radius * 1.0;
              show_unlock_hint = false;
            };
          }
        );

      # counter ids, the form noctalia assigns itself
      clockId = "lockscreen-widget-0000000000000001";
      dateId = "lockscreen-widget-0000000000000002";

      # a clock's text fills its box, so the date's is shorter, and wide enough for "Wednesday, September 30"
      clock = id: box: settings: {
        ${id} = widget primary {
          type = "clock";
          inherit box;

          settings = {
            background = false;
            center_text = true;
            shadow = false;
          }
          // settings;
        };
      };
    in
    {
      programs.noctalia.settings.lockscreen_widgets = {
        enabled = true;
        # primary first, then the rest by name, then the clock and the date
        widget_order =
          map (output: "lockscreen-login-box@${output}") ([ primary ] ++ lib.remove primary outputs)
          ++ [
            clockId
            dateId
          ];

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
