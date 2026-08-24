{ inputs, ... }:
{
  flake.modules.homeManager.noctalia =
    { lib, ... }:
    let
      monitors = inputs.self.monitors;
      outputs = lib.attrNames monitors;

      primary = lib.findFirst (name: monitors.${name}.primary or false) (lib.head outputs) outputs;

      loginBox = monitor: {
        name = "lockscreen-login-box@${monitor}";
        value = {
          type = "login_box";
          output = monitor;

          box_height = 70.0;
          box_width = 400.0;
          cx = 960.0;
          cy = 898.0;

          settings = {
            layout = "compact";
            background_color = "surface_variant";
            background_opacity = 0.0;
            background_radius = 0.0;
            center_password_text = true;
            input_opacity = 1.0;
            input_radius = 4.0;
            show_caps_lock = true;
            show_keyboard_layout = false;
            show_login_button = false;
            show_media = true;
            show_session_buttons = true;
            show_unlock_hint = false;
            show_weather = true;
          };
        };
      };

      loginBoxes = map loginBox outputs;
    in
    {
      programs.noctalia.settings.lockscreen = {
        monitors = [ primary ];
        allow_empty_password = true;
      };

      programs.noctalia.settings.lockscreen_widgets = {
        enabled = true;
        widget_order = map (entry: entry.name) loginBoxes;
        widget = lib.listToAttrs loginBoxes;
      };
    };
}
