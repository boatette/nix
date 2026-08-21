{
  flake.modules.niri.niri.settings = {
    cursor = {
      xcursor-theme = "capitaine-cursors";
      xcursor-size = 24;

      hide-when-typing = _: { };
      hide-after-inactive-ms = 5000;
    };

    prefer-no-csd = _: { };

    screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

    hotkey-overlay.skip-at-startup = _: { };

    blur = {
      passes = 4;
      offset = 6;
      noise = 0.03;
      saturation = 1;
    };

    environment = {
      XDG_SESSION_TYPE = "wayland";
      XDG_CURRENT_DESKTOP = "niri";
    };

    debug.honor-xdg-activation-with-invalid-serial = _: { };
  };
}
