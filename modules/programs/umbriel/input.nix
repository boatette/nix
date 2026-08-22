{
  flake.modules.homeManager.umbriel.programs.umbriel.settings.input = {
    middle_click_paste = true;

    keyboard = {
      layout = "us,us";
      variant = ",dvp";
      options = "caps:super,grp:win_space_toggle";
      repeat_rate = 25;
      repeat_delay = 600;
    };

    touchpad = {
      tap = true;
      natural_scroll = true;
    };

    mouse = {
      accel_profile = "flat";
      sensitivity = 0.0;
      scroll_wheel_step = 60;
    };

    cursor = {
      theme = "capitaine-cursors";
      size = 24;
      hardware_cursor = true;
      hide_when_typing = true;
      hide_timeout_ms = 5000;
    };

    focus.follows_mouse = false;
  };
}
