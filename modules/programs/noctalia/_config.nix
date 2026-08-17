{
  pkgs,
  homeDirectory ? "/home/boatette",
  monitors ? {
    "eDP-1".primary = true;
  },
}:

let
  inherit (pkgs) lib;

  templates = ./templates;

  outputs = lib.attrNames monitors;
  primaryMonitor = lib.findFirst (name: monitors.${name}.primary) "eDP-1" outputs;

  loginBox = monitor: {
    name = "lockscreen-login-box@${monitor}";
    value = {
      box_height = 70.0;
      box_width = 400.0;
      cx = 960.0;
      cy = 898.0;
      output = monitor;
      rotation = 0.0;
      type = "login_box";

      settings = {
        background_color = "surface_variant";
        background_opacity = 0.0;
        background_radius = 0.0;
        center_password_text = true;
        input_opacity = 1.0;
        input_radius = 0.0;
        layout = "compact";
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
  flakeDir = "${homeDirectory}/nix";
  args = {
    inherit
      lib
      pkgs
      monitors
      homeDirectory
      templates
      primaryMonitor
      loginBoxes
      flakeDir
      ;
  };

  sections = [
    ./_settings/bar.nix
    ./_settings/dock.nix
    ./_settings/hooks.nix
    ./_settings/lockscreen.nix
    ./_settings/plugins.nix
    ./_settings/shell.nix
    ./_settings/theme.nix
    ./_settings/widgets.nix
  ];
in

lib.foldl' lib.recursiveUpdate { } (map (section: import section args) sections)
